import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { fetchSportDetails } from '../services/api';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import { ChevronLeft, Calendar, Users, Newspaper, Trophy } from 'lucide-react'; // Example icons

function SportDetailScreen() {
    const { sportId } = useParams();
    const navigate = useNavigate();
    const [details, setDetails] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const loadData = async () => {
            setIsLoading(true); setError(null);
            try {
                const data = await fetchSportDetails(sportId);
                setDetails(data);
            } catch (err) { setError(err.message || "Could not load sport details."); console.error(err); }
            finally { setIsLoading(false); }
        };
        loadData();
    }, [sportId]);

    // Helper to format date
    const formatDate = (dateString) => dateString ? new Date(dateString + 'T00:00:00').toLocaleDateString('en-US', { month: 'short', day: 'numeric' }) : '';

    return (
        <div className="p-4">
            <header className="flex items-center mb-4 -ml-1">
                <button onClick={() => navigate(-1)} className="p-1 rounded-full hover:bg-gray-200" aria-label="Go back">
                    <ChevronLeft size={24} className="text-blue-600" />
                </button>
                <h1 className="text-xl font-bold ml-2">{details?.name || 'Sport Details'}</h1>
                 {/* Optional: Add season/coach here */}
                {details?.coach && <span className="ml-auto text-sm text-gray-500">Coach: {details.coach}</span>}
            </header>

            {isLoading && <LoadingSpinner />}
            {error && <ErrorMessage message={error} />}

            {!isLoading && !error && details && (
                <div className="space-y-6">
                    {/* --- Schedule Section --- */}
                    <div>
                        <h2 className="text-lg font-semibold mb-2 flex items-center"><Calendar size={18} className="mr-2 opacity-80"/> Schedule</h2>
                        <div className="bg-white rounded-lg shadow p-3 space-y-3">
                             {details.schedule && details.schedule.length > 0 ? (
                                details.schedule.map((item, index) => (
                                    <div key={index} className="text-sm border-b last:border-b-0 pb-2 last:pb-0">
                                        <div className="flex justify-between font-medium">
                                            <span>vs {item.opponent}</span>
                                            <span>{formatDate(item.date)} {item.time || ''}</span>
                                        </div>
                                         <div className="flex justify-between text-xs text-gray-500 mt-1">
                                            <span>{item.location}</span>
                                            {item.result && <span className={`font-semibold ${item.result.startsWith('W') ? 'text-green-600' : item.result.startsWith('L') ? 'text-red-600' : ''}`}>{item.result}</span>}
                                        </div>
                                    </div>
                                ))
                             ) : <p className="text-sm text-gray-500">Schedule not available.</p>}
                        </div>
                    </div>

                     {/* --- Roster Section --- */}
                     <div>
                        <h2 className="text-lg font-semibold mb-2 flex items-center"><Users size={18} className="mr-2 opacity-80"/> Roster</h2>
                        <div className="bg-white rounded-lg shadow p-3 space-y-2">
                             {details.roster && details.roster.length > 0 ? (
                                details.roster.map((player, index) => (
                                    <div key={index} className="flex justify-between text-sm">
                                        <span>{player.name}</span>
                                        <span className="text-gray-500">
                                            {player.number && `#${player.number}`} {player.year && `(${player.year})`}
                                        </span>
                                    </div>
                                ))
                             ) : <p className="text-sm text-gray-500">Roster not available.</p>}
                        </div>
                    </div>

                    {/* --- News Section --- */}
                    <div>
                        <h2 className="text-lg font-semibold mb-2 flex items-center"><Newspaper size={18} className="mr-2 opacity-80"/> News</h2>
                        <div className="bg-white rounded-lg shadow p-3 space-y-3">
                             {details.news && details.news.length > 0 ? (
                                details.news.map((newsItem) => (
                                    <div key={newsItem.id} className="text-sm pb-2 border-b last:border-b-0">
                                        <p className="font-medium">{newsItem.title}</p>
                                        <p className="text-xs text-gray-500 mt-1">{formatDate(newsItem.date)}</p>
                                        {/* Link to full article if needed */}
                                    </div>
                                ))
                             ) : <p className="text-sm text-gray-500">No recent news.</p>}
                        </div>
                    </div>

                    {/* Add other sections like Standings, Photos etc. based on Figma */}

                </div>
            )}
             {!isLoading && !error && !details && (
                 <p className="text-center text-gray-500 mt-8">Sport details not found.</p>
             )}
        </div>
    );
}
export default SportDetailScreen;
