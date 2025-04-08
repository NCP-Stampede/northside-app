import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight } from 'lucide-react';

function ScheduleBlock({ number, course, courseId }) { // Receive courseId
    const content = (
        <>
             <div className="flex-grow pr-2"> {/* Allow text wrap */}
                <h3 className="text-sm text-gray-500">Block {number}</h3>
                <p className="font-medium">{course}</p>
            </div>
            {courseId && <ChevronRight size={16} className="text-gray-400 flex-shrink-0" />} {/* Show arrow only if linkable */}
        </>
    );

    // Only wrap with Link if courseId exists (e.g., not for Lunch)
    if (courseId) {
        return (
            <Link
                to={`/grades/${courseId}`} // Link to Grade Detail Screen
                className="bg-white rounded-xl shadow-sm p-4 flex justify-between items-center hover:bg-gray-50 transition duration-150"
            >
                {content}
            </Link>
        );
    } else {
         // Render non-linkable block (e.g., Lunch)
        return (
             <div className="bg-white rounded-xl shadow-sm p-4 flex justify-between items-center opacity-70">
                {content}
             </div>
        );
    }
}
export default ScheduleBlock;
