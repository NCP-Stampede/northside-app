import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { fetchTardyDetails } from '../services/api';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import { ChevronLeft } from 'lucide-react';

function TardyDetailScreen() {
    const { tardyId } = useParams();
    const navigate = useNavigate();
    const [details, setDetails] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const loadData = async () => {
            setIsLoading(true); setError(null);
            try {
                const data = await fetchTardyDetails(tardyId);
                setDetails(data);
            } catch (err) { setError(err.message || "Could not load tardy details."); console.error(err); }
            finally { setIsLoading(false); }
        };
        loadData();
    }, [tardyId]);

    return (
        <div className="p-4">
            <header className="flex items-center mb-4 -ml-1">
                <button onClick={() => navigate(-1)} className="p-1 rounded-full hover:bg-gray-200" aria-label="Go back">
                    <ChevronLeft size={24} className="text-blue-600" />
                </button>
                <h1 className="text-xl font-bold ml-2">Tardy Details</h1>
            </header>

             {isLoading && <LoadingSpinner />}
            {error && <ErrorMessage message={error} />}

             {!isLoading && !error && details && (
                <div className="bg-white p-4 rounded-lg shadow space-y-3">
                    <div className="pb-2 border-b">
                        <label className="text-xs text-gray-500">Course</label>
                        <p className="font-medium">{details.course}</p>
                    </div>
                     <div className="pb-2 border-b">
                        <label className="text-xs text-gray-500">Teacher</label>
                        <p className="font-medium">{details.teacher}</p>
                    </div>
                     <div className="pb-2 border-b">
                        <label className="text-xs text-gray-500">Date & Time</label>
                        <p className="font-medium">{details.date} at {details.time}</p>
                    </div>
                    <div className="pb-2 border-b">
                        <label className="text-xs text-gray-500">Details</label>
                        <p className="font-medium">{details.details}</p>
                    </div>
                    <div>
                         <label className="text-xs text-gray-500">Status</label>
                        <p className={`font-semibold ${details.excused ? 'text-green-600' : 'text-red-600'}`}>
                            {details.excused ? 'Excused' : 'Unexcused'}
                        </p>
                    </div>
                    {/* Add any actions if applicable (e.g., dispute button) */}
                </div>
            )}
             {!isLoading && !error && !details && (
                 <p className="text-center text-gray-500 mt-8">Tardy record not found.</p>
             )}
        </div>
    );
}

export default TardyDetailScreen;
