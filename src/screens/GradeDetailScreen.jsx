import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { fetchGradeDetails } from '../services/api';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import GradeCategory from '../components/GradeCategory'; // Import component
import AssignmentItem from '../components/AssignmentItem'; // Import component
import { ChevronLeft } from 'lucide-react';

function GradeDetailScreen() {
    const { courseId } = useParams();
    const navigate = useNavigate();
    const [details, setDetails] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const loadData = async () => {
            setIsLoading(true);
            setError(null);
            try {
                const data = await fetchGradeDetails(courseId);
                setDetails(data);
            } catch (err) {
                console.error("Failed to fetch grade details:", err);
                setError(err.message || 'Could not load grade details.');
            } finally {
                setIsLoading(false);
            }
        };
        loadData();
    }, [courseId]);

    // Determine overall grade color
    const getOverallColor = (percentage) => {
        if (percentage === null || percentage === undefined) return 'text-gray-600';
        return percentage >= 90 ? 'text-green-600' : percentage >= 80 ? 'text-yellow-600' : percentage >= 70 ? 'text-orange-500' : 'text-red-600';
    };
    const overallPercentageColor = getOverallColor(details?.overallPercentage);


    return (
        <div className="p-4">
             <header className="flex items-center mb-4 -ml-1">
                <button onClick={() => navigate(-1)} className="p-1 rounded-full hover:bg-gray-200" aria-label="Go back">
                    <ChevronLeft size={24} className="text-blue-600" />
                </button>
                <div className="ml-2 flex-grow overflow-hidden">
                    <h1 className="text-xl font-bold truncate">{details?.courseName || 'Course Details'}</h1>
                    {details?.teacher && <p className="text-xs text-gray-500">{details.teacher}</p>}
                </div>
            </header>

            {isLoading && <LoadingSpinner />}
            {error && <ErrorMessage message={error} /> /* Show error even if some details loaded */}

            {!isLoading && !details && !error && (
                 <p className="text-center text-gray-500 mt-8">Grade details not found for this course.</p>
            )}

            {details && (
                <>
                    {/* Overall Percentage Display */}
                    <div className="text-center mb-6 py-4 bg-white rounded-lg shadow">
                        <div className={`text-5xl font-bold ${overallPercentageColor}`}>{details.overallPercentage != null ? `${details.overallPercentage}%` : 'N/A'}</div>
                        <div className="text-sm text-gray-500 mt-1">Cumulative Grade</div>
                    </div>

                    {/* Categories Section */}
                    <h2 className="text-lg font-semibold mb-2">Categories</h2>
                    {details.categories?.length > 0 ? (
                         details.categories.map(cat => (
                            <GradeCategory key={cat.name} {...cat} />
                        ))
                    ) : (
                        <p className="text-gray-500 text-sm bg-white p-3 rounded-lg shadow mb-6">No category breakdown available.</p>
                    )}


                    {/* Assignments Section */}
                    <h2 className="text-lg font-semibold mb-2 mt-6">Assignments</h2>
                    <div className="bg-white rounded-lg shadow p-3">
                       {details.assignments?.length > 0 ? (
                            details.assignments.map(assign => (
                                <AssignmentItem key={assign.id} {...assign} />
                            ))
                        ) : (
                            <p className="text-gray-500 text-sm text-center py-4">No assignments listed.</p>
                        )}
                    </div>
                </>
            )}
        </div>
    );
}

export default GradeDetailScreen;
