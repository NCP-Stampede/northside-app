import React from 'react';
import { Link } from 'react-router-dom';

function CalendarDay({ day, year, month }) { // Receive year/month for link generation
    const isToday = day.isToday;
    const isCurrentMonth = day.isCurrentMonth;

    // Format the date as YYYY-MM-DD for the URL
    const dateString = (year && month !== undefined && isCurrentMonth)
        ? `${year}-${String(month + 1).padStart(2, '0')}-${String(day.date).padStart(2, '0')}`
        : null;

    const dayContent = (
         <div
            className={`
                h-8 w-8 flex items-center justify-center rounded-full text-sm mx-auto border border-transparent group-hover:border-blue-200
                ${isToday ? 'bg-blue-500 text-white font-semibold' : ''}
                ${!isCurrentMonth ? 'text-gray-300' : 'text-gray-700'}
                ${isCurrentMonth && !isToday ? 'hover:bg-blue-100' : ''}
            `}
        >
            {day.date}
        </div>
    );

    // Only link days in the current month
    if (isCurrentMonth && dateString) {
        return (
             <Link to={`/events/${dateString}`} className="block group" aria-label={`Events for ${dateString}`}>
                 {dayContent}
             </Link>
        );
    }

    // Render non-linkable day (past/future month or if year/month missing)
    return <div className="h-8 w-8 flex items-center justify-center">{dayContent}</div>;
}
export default CalendarDay;
