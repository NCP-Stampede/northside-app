import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchSchedule } from '../services/api';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import ScheduleBlock from '../components/ScheduleBlock'; // Import component
import { ChevronLeft } from 'lucide-react';

function ScheduleScreen() {
    const navigate = useNavigate();
    const [scheduleData, setScheduleData] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const loadData = async () => {
            setIsLoading(true); setError(null);
            try {
                const data = await fetchSchedule();
                setScheduleData(data);
            } catch (err) { setError("Failed to load schedule."); console.error(err); }
            finally { setIsLoading(false); }
        };
        loadData();
    }, []);

  return (
    <div className="p-4">
      <header className="mb-4">
        <div className="flex items-center -ml-1">
            <button onClick={() => navigate(-1)} className="p-1 rounded-full hover:bg-gray-200" aria-label="Go back">
                <ChevronLeft size={24} className="text-blue-600" />
            </button>
            <h1 className="text-xl font-bold ml-2">Schedule</h1>
        </div>
        {/* Display dynamic date */}
        {scheduleData?.date && <div className="text-sm text-blue-500 mt-1 ml-8">{scheduleData.date}</div>}
      </header>

        {isLoading && <LoadingSpinner />}
        {error && <ErrorMessage message={error} />}

        {!isLoading && !error && scheduleData?.blocks && (
             <div className="space-y-3">
                {scheduleData.blocks.length > 0 ? (
                    scheduleData.blocks.map(block => (
                         // Pass courseId for linking
                        <ScheduleBlock key={block.id} {...block} courseId={block.courseId} />
                    ))
                ) : (
                     <p className="text-center text-gray-500 mt-8">Schedule not available for this day.</p>
                )}
            </div>
        )}
         {!isLoading && !error && !scheduleData?.blocks && (
             <p className="text-center text-gray-500 mt-8">Could not load schedule.</p>
        )}
    </div>
  );
}

export default ScheduleScreen;
