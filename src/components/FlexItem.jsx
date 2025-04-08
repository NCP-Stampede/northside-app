import React from 'react';
import { Link } from 'react-router-dom';
import { ChevronRight } from 'lucide-react';

function FlexItem({ id, name, status /* Add more data if needed */ }) {
    const isAvailable = status === 'available'; // Example status logic
    const isUpcoming = status === 'upcoming';

    return (
        <div className="mb-4">
            <h2 className="text-lg font-semibold mb-2">{name}</h2>
            <Link
                to={`/flexes/${id}`}
                className={`bg-white rounded-xl shadow-sm p-4 flex justify-between items-center transition duration-150 ${
                    isAvailable || isUpcoming ? 'cursor-pointer hover:bg-gray-50' : 'opacity-60 cursor-not-allowed' // Allow click for upcoming
                }`}
                // Prevent navigation only if completely unavailable (add more statuses if needed)
                // onClick={(e) => !(isAvailable || isUpcoming) && e.preventDefault()}
            >
                <span className="font-medium">
                    {isAvailable ? `Register for ${name}` : isUpcoming ? `View Options (Upcoming)` : 'View Details'}
                </span>
                 {/* Show chevron if clickable */}
                 {(isAvailable || isUpcoming) && <ChevronRight size={16} className="text-blue-500" />}
                 {!(isAvailable || isUpcoming) && <ChevronRight size={16} className="text-gray-400" />}
            </Link>
        </div>
    );
}
export default FlexItem;
