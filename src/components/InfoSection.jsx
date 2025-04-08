import React from 'react';

// Reusable component for info sections shown in Figma (e.g., Athletic Profile)
function InfoSection({ title, children }) {
    return (
        <div className="bg-white rounded-lg shadow p-4 mb-4">
            <h2 className="text-sm font-semibold text-gray-500 mb-3 uppercase tracking-wide">{title}</h2>
            <div className="space-y-2">
                {children}
            </div>
        </div>
    );
}
export default InfoSection;
