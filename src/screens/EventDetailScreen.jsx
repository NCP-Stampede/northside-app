import React, {useState, useEffect} from 'react';
import { Link } from 'react-router-dom'; // Keep Link
import { fetchAthletics } from '../services/api';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import { ChevronRight } from 'lucide-react';
import FeaturedStoryCard from '../components/FeaturedStoryCard'; // Import component

// Card for linking to All Sports
function AllSportsLinkCard() {
    return (
        <Link to="/athletics/sports" className="bg-white rounded-xl shadow-sm p-4 flex items-center justify-between hover:bg-gray-50 transition duration-150">
            <span className="font-medium">View All Sports</span>
            <ChevronRight size={16} className="text-gray-400" />
        </Link>
    )
}

function AthleticsScreen() {
    const [athleticsData, setAthleticsData] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);

     useEffect(() => {
        // Fetch featured story
        const loadData = async () => {
            setIsLoading(true);
            setError(null);
            try {
                const data = await fetchAthletics(); // Fetches { featuredStory: {...} }
                setAthleticsData(data);
            } catch (err) {
                setError("Failed to load athletics data.");
                console.error(err);
            } finally {
                setIsLoading(false);
            }
        };
        loadData();
    }, []);


    return (
        <div className="p-4">
            <header className="mb-4">
                <h1 className="text-2xl font-bold">Athletics</h1>
            </header>

            {isLoading && <LoadingSpinner />}
            {error && <ErrorMessage message={error} />}

            {!isLoading && !error && athleticsData?.featuredStory && (
                 <FeaturedStoryCard {...athleticsData.featuredStory} slug={"#"}/> // Use real slug if featured story links
            )}

            {!isLoading && !error && (
                <>
                    <h2 className="text-lg font-semibold mb-3 mt-6">Sports</h2>
                    {/* Link to All Sports */}
                    <AllSportsLinkCard />
                </>
            )}
        </div>
    );
}
export default AthleticsScreen;
