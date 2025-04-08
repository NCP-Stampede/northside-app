import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import ProfileSection from '../components/ProfileSection';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import { fetchProfileData, logoutUser } from '../services/api';
import { User, Clock, Award, Bell, LogOut } from 'lucide-react';
// import { useAuth } from '../contexts/AuthContext'; // Import if using context

function ProfileScreen() {
    const navigate = useNavigate();
    // const { logout } = useAuth(); // Use context logout if implemented
    const [profile, setProfile] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);
    const [isLoggingOut, setIsLoggingOut] = useState(false);

     useEffect(() => {
        const loadData = async () => {
            setIsLoading(true); setError(null);
            try {
                const data = await fetchProfileData();
                setProfile(data);
            } catch (err) { setError("Failed to load profile data."); console.error(err); }
            finally { setIsLoading(false); }
        };
        loadData();
    }, []);

    const handleLogout = async () => {
        setIsLoggingOut(true);
        try {
            await logoutUser(); // Call mock API
            // logout(); // Call context logout function to clear state/token
             // Redirect handled by App.jsx based on isAuthenticated state change
            console.log("Logged out successfully (mock)");
             navigate('/login', { replace: true }); // Manual redirect if not using context based protection
        } catch (err) {
            console.error("Logout failed:", err);
            // Show error to user?
             setIsLoggingOut(false);
        }
         // No finally needed if redirecting on success
    };

  return (
    <div className="p-4">
        {isLoading && <div className="pt-10"><LoadingSpinner /></div> }
        {error && <ErrorMessage message={error} />}

        {!isLoading && !error && profile && (
            <>
                <header className="flex flex-col items-center mb-6 text-center">
                    <div className="w-24 h-24 bg-gray-300 rounded-full mb-3 flex items-center justify-center overflow-hidden">
                        {profile.profilePicUrl ? (
                             <img src={profile.profilePicUrl} alt="Profile" className="w-full h-full object-cover"/>
                        ) : (
                             <User size={48} className="text-gray-500" />
                        )}
                    </div>
                    <h1 className="text-2xl font-bold">{profile.name}</h1>
                    <p className="text-sm text-gray-500">{profile.gradeLevel} • {profile.school}</p>
                </header>

                <div className="space-y-4">
                    <ProfileSection
                      title="My Info"
                      icon={<User size={16} />}
                      to="/profile/info" // Use 'to' prop for Link
                    />
                    <ProfileSection
                      title="Schedule"
                      icon={<Clock size={16} />}
                      to="/profile/schedule" // Use 'to' prop for Link
                    />
                    <ProfileSection
                      title="Your Athletic Profile"
                      icon={<Award size={16} />}
                      subtitle="View your athletic participation and sports"
                      to="/profile/athletic" // Use 'to' prop for Link
                    />
                    {/* Add link for Athletic Account if needed */}
                    {/* <ProfileSection
                      title="Your Athletic Account"
                      icon={<Award size={16} />}
                      subtitle="Use your account for the latest athletic purchases"
                      to="/profile/athletic-account" // Example link
                    /> */}
                    <ProfileSection
                      title="Flex Account"
                      icon={<Bell size={16} />}
                      subtitle="Link your flex account to your Hoofbeat account" // Maybe just link to flexes?
                      to="/flexes" // Use 'to' prop for Link
                    />

                    <div className="mt-8">
                    <button
                        onClick={handleLogout}
                        disabled={isLoggingOut}
                        className="w-full py-3 bg-red-500 text-white rounded-lg font-medium flex items-center justify-center hover:bg-red-600 disabled:opacity-70"
                    >
                        {isLoggingOut ? (
                            <>
                                <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                </svg>
                                Logging Out...
                            </>
                        ) : (
                             <>
                                <LogOut size={16} className="mr-2" />
                                Log Out
                             </>
                        )}
                    </button>
                    </div>
                </div>
            </>
        )}
    </div>
  );
}

export default ProfileScreen;
