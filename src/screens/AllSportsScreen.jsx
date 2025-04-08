import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchAllSports } from '../services/api';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import SportListItem from '../components/SportListItem'; // Import component
import { ChevronLeft } from 'lucide-react';

function AllSportsScreen() {
    const navigate = useNavigate();
    const [sports, setSports] = useState([]);
    const [filter, setFilter] = useState('all'); // 'all', 'fall', 'winter', 'spring'
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const loadData = async () => {
            setIsLoading(true);
            setError(null);
            try {
                const data = await fetchAllSports({ filter });
                setSports(data);
            } catch (err) {
                setError('Failed to load sports list.');
                console.error(err);
            } finally {
                setIsLoading(false);
            }
        };
        loadData();
    }, [filter]);

    const FilterButton = ({ value, label }) => (
         <button
             onClick={() => setFilter(value)}
             className={`px-4 py-1 rounded-full text-sm font-medium transition-colors duration-150 ${
                 filter === value ? 'bg-blue-500 text-white' : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
             }`}
         >
             {label}
         </button>
     );


    return (
        <div className="p-4">
            <header className="flex items-center mb-4 -ml-1">
                 <button onClick={() => navigate(-1)} className="p-1 rounded-full hover:bg-gray-200" aria-label="Go back">
                    <ChevronLeft size={24} className="text-blue-600" />
                </button>
                <h1 className="text-xl font-bold ml-2">All Sports</h1>
            </header>

            {/* Filter Buttons */}
            <div className="flex space-x-2 mb-6 overflow-x-auto pb-2">
                <FilterButton value="all" label="All" />
                <FilterButton value="fall" label="Fall" />
                <FilterButton value="winter" label="Winter" />
                <FilterButton value="spring" label="Spring" />
            </div>

            {isLoading && <LoadingSpinner />}
            {error && <ErrorMessage message={error} />}

            {!isLoading && !error && (
                <div>
                    {sports.length > 0 ? (
                        sports.map(sport => <SportListItem key={sport.id} {...sport} />)
                    ) : (
                        <p className="text-center text-gray-500 mt-8">No sports found for this season.</p>
                    )}
                </div>
            )}
        </div>
    );
}

export default AllSportsScreen;
