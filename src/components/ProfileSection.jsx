import React from 'react';
import { ChevronRight } from 'lucide-react';
import { Link } from 'react-router-dom';

// Use 'to' prop for Link destination. Fallback to onClick for non-link actions (like logout).
function ProfileSection({ title, icon, subtitle, to, onClick }) {
    const content = (
        <div className="flex items-center justify-between w-full">
             <div className="flex items-center">
                {icon && <div className="text-blue-500 mr-3 flex-shrink-0">{icon}</div>}
                <div>
                    <h3 className="font-medium">{title}</h3>
                    {subtitle && <p className="text-xs text-gray-500">{subtitle}</p>}
                </div>
            </div>
            {/* Show chevron only if it's a link or has onClick */}
            {(to || onClick) && <ChevronRight size={16} className="text-gray-400 flex-shrink-0" />}
        </div>
    );

    if (to) {
        return (
             <Link
                to={to}
                className="bg-white rounded-xl shadow-sm p-4 flex items-center justify-between cursor-pointer hover:bg-gray-50 transition duration-150 w-full"
            >
                 {content}
            </Link>
        );
    }

    if (onClick) {
        return (
             <button
                onClick={onClick}
                className="bg-white rounded-xl shadow-sm p-4 flex items-center justify-between cursor-pointer hover:bg-gray-50 transition duration-150 w-full text-left"
            >
                 {content}
            </button>
        );
    }

    // Non-interactive version
    return (
         <div className="bg-white rounded-xl shadow-sm p-4 flex items-center justify-between w-full">
             {content}
         </div>
    );
}
export default ProfileSection;
