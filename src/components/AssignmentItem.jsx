import React from 'react';
import { Link } from 'react-router-dom'; // Optional: If assignments link somewhere

// Helper component for assignments list item - used in GradeDetailScreen
function AssignmentItem({ id, name, category, dueDate, score }) {
    // Decide if assignments are linkable
    const isLinkable = false; // Set to true and provide 'to' if needed
    const to = `/assignment/${id}`; // Example link

    const content = (
        <div className="py-3 border-b border-gray-100 last:border-b-0">
            <div className="flex justify-between items-center">
                <span className="font-medium text-sm">{name}</span>
                <span className="text-sm font-semibold">{score || 'Not Graded'}</span>
            </div>
            <div className="text-xs text-gray-500 mt-1">
                <span>{category}</span> • <span>Due: {dueDate}</span>
            </div>
        </div>
    );

    if (isLinkable) {
        return <Link to={to} className="block hover:bg-gray-50 -mx-3 px-3">{content}</Link>
    }

    return content;
}

export default AssignmentItem;
