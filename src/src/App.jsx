import React from 'react';
import { Routes, Route, useLocation, Navigate } from 'react-router-dom';

// Core Components
import NavBar from './components/NavBar';
import LoadingSpinner from './components/LoadingSpinner'; // Optional: For global loading state later

// Screen Components (Import all)
import HomeScreen from './screens/HomeScreen';
import EventsScreen from './screens/EventsScreen';
import EventDetailScreen from './screens/EventDetailScreen';
import AthleticsScreen from './screens/AthleticsScreen';
import AllSportsScreen from './screens/AllSportsScreen';
import SportDetailScreen from './screens/SportDetailScreen';
import GradesScreen from './screens/GradesScreen';
import GradeDetailScreen from './screens/GradeDetailScreen';
import ProfileScreen from './screens/ProfileScreen';
import StudentInfoScreen from './screens/StudentInfoScreen';
import ScheduleScreen from './screens/ScheduleScreen';
import AthleticProfileScreen from './screens/AthleticProfileScreen';
import HoofBeatScreen from './screens/HoofBeatScreen';
import ArticleDetailScreen from './screens/ArticleDetailScreen';
import FlexesScreen from './screens/FlexesScreen';
import PickFlexScreen from './screens/PickFlexScreen';
import AttendanceScreen from './screens/AttendanceScreen';
import TardyDetailScreen from './screens/TardyDetailScreen';
import LoginScreen from './screens/LoginScreen';
import NotFoundScreen from './screens/NotFoundScreen';

// --- Auth Placeholder ---
// import { AuthProvider, useAuth } from './contexts/AuthContext';
// function ProtectedRoute({ children }) { ... }

function App() {
    const location = useLocation();
    // Example: Hide NavBar on login or specific auth routes
    const showNavBar = !['/login'].includes(location.pathname) && !location.pathname.startsWith('/auth');

    // --- Basic Auth Simulation (Replace with context/state management later) ---
    const isAuthenticated = true; // Assume logged in for now. Set to false to test redirect.
    // const { isAuthenticated, isLoadingAuth } = useAuth(); // Example if using context

    // Optional: Show loading spinner during initial auth check
    // if (isLoadingAuth) {
    //    return <div className="flex justify-center items-center h-screen"><LoadingSpinner /></div>;
    // }

    return (
        // <AuthProvider> {/* Wrap if using Auth Context */}
        <div className="flex flex-col min-h-screen bg-gray-100 font-sans">
            <main className={`flex-1 overflow-y-auto ${showNavBar ? 'pb-16' : ''}`}>
                <Routes>
                    {/* Public Route */}
                    <Route path="/login" element={!isAuthenticated ? <LoginScreen /> : <Navigate to="/" replace />} />

                    {/* Protected Routes */}
                    <Route path="/" element={isAuthenticated ? <HomeScreen /> : <Navigate to="/login" replace />} />
                    <Route path="/home" element={isAuthenticated ? <HomeScreen /> : <Navigate to="/login" replace />} />

                    {/* Events */}
                    <Route path="/events" element={isAuthenticated ? <EventsScreen /> : <Navigate to="/login" replace />} />
                    <Route path="/events/:eventDate" element={isAuthenticated ? <EventDetailScreen /> : <Navigate to="/login" replace />} />

                    {/* Athletics */}
                    <Route path="/athletics" element={isAuthenticated ? <AthleticsScreen /> : <Navigate to="/login" replace />} />
                    <Route path="/athletics/sports" element={isAuthenticated ? <AllSportsScreen /> : <Navigate to="/login" replace />} />
                    <Route path="/athletics/sports/:sportId" element={isAuthenticated ? <SportDetailScreen /> : <Navigate to="/login" replace />} />

                    {/* Grades */}
                    <Route path="/grades" element={isAuthenticated ? <GradesScreen /> : <Navigate to="/login" replace />} />
                    <Route path="/grades/:courseId" element={isAuthenticated ? <GradeDetailScreen /> : <Navigate to="/login" replace />} />

                    {/* Profile */}
                    <Route path="/profile" element={isAuthenticated ? <ProfileScreen /> : <Navigate to="/login" replace />} />
                    <Route path="/profile/info" element={isAuthenticated ? <StudentInfoScreen /> : <Navigate to="/login" replace />} />
                    <Route path="/profile/schedule" element={isAuthenticated ? <ScheduleScreen /> : <Navigate to="/login" replace />} />
                    <Route path="/profile/athletic" element={isAuthenticated ? <AthleticProfileScreen /> : <Navigate to="/login" replace />} />
                    {/* Add route for Athletic Account if needed */}

                    {/* Hoofbeat */}
                    <Route path="/hoofbeat" element={isAuthenticated ? <HoofBeatScreen /> : <Navigate to="/login" replace />} />
                    <Route path="/hoofbeat/:articleSlug" element={isAuthenticated ? <ArticleDetailScreen /> : <Navigate to="/login" replace />} />

                    {/* Flexes */}
                    <Route path="/flexes" element={isAuthenticated ? <FlexesScreen /> : <Navigate to="/login" replace />} />
                    <Route path="/flexes/:flexId" element={isAuthenticated ? <PickFlexScreen /> : <Navigate to="/login" replace />} />

                    {/* Attendance */}
                    <Route path="/attendance" element={isAuthenticated ? <AttendanceScreen /> : <Navigate to="/login" replace />} />
                    <Route path="/attendance/tardies/:tardyId" element={isAuthenticated ? <TardyDetailScreen /> : <Navigate to="/login" replace />} />

                    {/* Catch-all Not Found Route */}
                    <Route path="*" element={<NotFoundScreen />} />
                </Routes>
            </main>
            {isAuthenticated && showNavBar && <NavBar />} {/* Show NavBar only if authenticated and not on specific pages */}
        </div>
        // </AuthProvider>
    );
}

export default App;
