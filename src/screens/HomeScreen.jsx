import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import QuickLinkCard from '../components/QuickLinkCard';
import PromotionCard from '../components/PromotionCard';
import { BookOpen, Calendar, Bell, Info, User } from 'lucide-react';
import LoadingSpinner from '../components/LoadingSpinner'; // Assuming you might fetch data later
import ErrorMessage from '../components/ErrorMessage'; // Assuming you might fetch data later

function HomeScreen() {
  // Placeholder state if fetching promotions or other dynamic data
  // const [promoData, setPromoData] = useState(null);
  // const [isLoading, setIsLoading] = useState(true);
  // const [error, setError] = useState(null);

  // Placeholder useEffect for fetching data
  // useEffect(() => {
  //   const loadData = async () => {
  //     // Fetch data here (e.g., promotions)
  //     setIsLoading(false);
  //   };
  //   loadData();
  // }, []);

  // Replace with dynamic data later
  const isLoading = false;
  const error = null;
  const promoData = {
    title: "Homecoming 2024",
    date: "Fri, October 25th", // Make date more specific
    image: "/api/placeholder/400/200", // Use a real path or fetch from API
    to: "/events" // Optional link destination
  };

  const profileData = {
      name: "John", // Fetch this later
      profilePicUrl: null // Fetch this later
  }

  return (
    <div className="p-4">
      <header className="flex items-center justify-between mb-6">
        <div>
            <h1 className="text-2xl font-bold">Home</h1>
            <p className="text-sm text-gray-500">Welcome, {profileData.name}!</p> {/* Greeting */}
        </div>
        {/* Link to Profile */}
        <Link to="/profile" className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
            {profileData.profilePicUrl ? (
                <img src={profileData.profilePicUrl} alt="Profile" className="w-full h-full object-cover"/>
            ) : (
                <User size={20} className="text-gray-500"/>
            )}
        </Link>
      </header>

      {isLoading && <LoadingSpinner />}
      {error && <ErrorMessage message={error} />}

      {!isLoading && !error && (
        <>
          {/* Quick Links */}
          <div className="grid grid-cols-2 gap-4 mb-6">
            <QuickLinkCard
              icon={<BookOpen size={20} />}
              title="Grades"
              color="bg-blue-500"
              to="/grades" // Use 'to' prop for Link
            />
            <QuickLinkCard
              icon={<Calendar size={20} />}
              title="Events"
              color="bg-purple-500"
              to="/events" // Use 'to' prop for Link
            />
            <QuickLinkCard
              icon={<Info size={20} />}
              title="HoofBeat"
              color="bg-green-500"
              to="/hoofbeat" // Use 'to' prop for Link
            />
            <QuickLinkCard
              icon={<Bell size={20} />}
              title="Flexes"
              color="bg-orange-500"
              to="/flexes" // Use 'to' prop for Link
            />
          </div>

          {/* Upcoming Section */}
          {promoData && (
             <div className="mb-6">
                <h2 className="text-lg font-semibold mb-3">Upcoming</h2>
                <div className="bg-white rounded-xl shadow-sm overflow-hidden">
                  {/* Pass data to PromotionCard */}
                  <PromotionCard {...promoData} />
                </div>
            </div>
          )}

           {/* Add other sections as needed (e.g., recent notifications) */}

        </>
      )}
    </div>
  );
}

export default HomeScreen;
