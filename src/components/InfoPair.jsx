import React from 'react';

// Reusable component for label/value pairs (e.g., Athletic Profile)
function InfoPair({ label, value }) {
    return (
        <div>
            <label className="block text-xs text-gray-500">{label}</label>
            <div className="font-medium text-sm">{value || '-'}</div> {/* Added fallback */}
        </div>
    );
}
export default InfoPair;
