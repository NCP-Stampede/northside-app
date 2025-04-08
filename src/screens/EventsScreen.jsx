import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { generateCalendarDays } from '../utils/calendarUtils'; // Use util
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { fetchEvents } from '../services/api';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import CalendarDay from '../components/CalendarDay'; // Import CalendarDay component

function EventsScreen() {
    // State for the currently displayed month/year
    const [currentDate, setCurrentDate] = useState(new Date());
    const [calendarData, setCalendarData] = useState({ monthLabel: '', days: [] });
    // Add loading/error for actual event fetching
    const [isLoadingEvents, setIsLoadingEvents] = useState(false); // Set true if fetching events on load
    const [eventsError, setEventsError] = useState(null);
    // State to hold events for the month (optional, for marking days)
    // const [monthEvents, setMonthEvents] = useState({});

    const currentYear = currentDate.getFullYear();
    const currentMonth = currentDate.getMonth(); // 0-indexed

    useEffect(() => {
        // Generate calendar days based on currentDate
        const days = generateCalendarDays(currentYear, currentMonth); // Pass current year/month
        const monthLabel = currentDate.toLocaleString('default', { month: 'long', year: 'numeric' });
        setCalendarData({ monthLabel, days });

        // Example: Fetch events for the current month
        const loadEvents = async () => {
            setIsLoadingEvents(true);
            setEventsError(null);
            try {
                // Pass current month/year to API (API needs implementation)
                const events = await fetchEvents({ month: currentMonth + 1, year: currentYear });
                // TODO: Process events and update calendar days state or store separately
                // Example: Mark days with events
                // const eventMap = {}; // build map of date -> hasEvent: true
                // setMonthEvents(eventMap);
            } catch (err) {
                setEventsError("Failed to load events.");
                console.error(err);
            } finally {
                setIsLoadingEvents(false);
            }
        };
        // loadEvents(); // Uncomment when API is ready

    }, [currentDate, currentYear, currentMonth]); // Re-run when month changes

    const handlePrevMonth = () => {
        setCurrentDate(prevDate => {
            const newDate = new Date(prevDate);
            newDate.setMonth(newDate.getMonth() - 1);
            return newDate;
        });
    };

    const handleNextMonth = () => {
         setCurrentDate(prevDate => {
            const newDate = new Date(prevDate);
            newDate.setMonth(newDate.getMonth() + 1);
            return newDate;
        });
    };

    return (
        <div className="p-4">
            <header className="mb-4">
                <h1 className="text-2xl font-bold">Events</h1>
                {/* <div className="text-sm text-blue-500">For Current Year</div> */}
            </header>

            <div className="bg-white rounded-xl shadow-sm p-4 mb-6">
                <div className="flex justify-between items-center mb-4">
                    <h2 className="font-semibold">{calendarData.monthLabel}</h2>
                    <div className="flex space-x-2">
                        <button onClick={handlePrevMonth} className="w-6 h-6 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200" aria-label="Previous month">
                            <ChevronLeft size={16} />
                        </button>
                        <button onClick={handleNextMonth} className="w-6 h-6 flex items-center justify-center rounded-full bg-gray-100 hover:bg-gray-200" aria-label="Next month">
                            <ChevronRight size={16} />
                        </button>
                    </div>
                </div>

                {/* Calendar Grid */}
                <div className="grid grid-cols-7 gap-1 text-center">
                    {['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day, i) => (
                        <div key={`header-${i}`} className="text-xs font-semibold text-gray-500 h-8 flex items-center justify-center">{day}</div>
                    ))}
                    {calendarData.days.map((day, i) => (
                        // Pass year/month for link generation
                         <CalendarDay key={`day-${i}`} day={day} year={currentYear} month={currentMonth} />
                         // TODO: Add visual indicator if day has events based on monthEvents state
                    ))}
                </div>
            </div>

            {/* Events List for selected day (Placeholder - Link handles navigation) */}
            <div className="bg-white rounded-xl shadow-sm p-4">
                {isLoadingEvents && <LoadingSpinner />}
                {eventsError && <ErrorMessage message={eventsError} />}
                {!isLoadingEvents && !eventsError && (
                    <p className="text-center text-gray-500">Select a day on the calendar to view events.</p>
                )}
                 {/* In a real app, you might fetch and show events for 'today' by default */}
            </div>
        </div>
    );
}
export default EventsScreen;
