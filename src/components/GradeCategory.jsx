import React from 'react';

// Helper component for category breakdown - used in GradeDetailScreen
function GradeCategory({ name, percentage, score }) {
    const percentageColor = percentage >= 90 ? 'text-green-600' : percentage >= 80 ? 'text-yellow-600' : percentage >= 70 ? 'text-orange-500' : 'text-red-600';
    const progressBarColor = percentage >= 90 ? 'bg-green-500' : percentage >= 80 ? 'bg-yellow-500' : percentage >= 70 ? 'bg-orange-500' : 'bg-red-500';

    return (
        <div className="bg-white rounded-lg shadow p-3 mb-3">
            <div className="flex justify-between items-center mb-2">
                <span className="font-semibold text-sm">{name}</span>
                <span className={`font-bold text-lg ${percentageColor}`}>
                    {percentage != null ? `${percentage}%` : 'N/A'}
                </span>
            </div>
            {/* Progress Bar */}
            <div className="w-full bg-gray-200 rounded-full h-1.5 dark:bg-gray-700">
                <div className={`${progressBarColor} h-1.5 rounded-full`} style={{ width: `${percentage}%` }}></div>
            </div>
            {/* Optional: Display letter score if provided */}
            {/* {score && <p className="text-xs text-gray-500 mt-1 text-right">{score}</p>} */}
        </div>
    );
}

export default GradeCategory;
