import React, { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
// import { useAuth } from '../contexts/AuthContext'; // Import if using context
import { loginUser } from '../services/api'; // Import mock API
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import { Lock, User } from 'lucide-react'; // Icons

function LoginScreen() {
    const navigate = useNavigate();
    const location = useLocation();
    // const { login } = useAuth(); // Use context login function if implemented
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState(null);
    const [isLoading, setIsLoading] = useState(false);

    const from = location.state?.from?.pathname || "/"; // Redirect back after login

    const handleSubmit = async (event) => {
        event.preventDefault();
        setError(null);
        setIsLoading(true);
        try {
            // Use mock API function for now
            const result = await loginUser(username, password);
            // Replace with context login if using AuthContext
            console.log("Login Success (Mock):", result);
             // Simulate setting auth state and redirecting
             // In real app, context would handle this state change
             // login(result.user, result.token); // Example context usage

             // For simulation without context, manually trigger navigation
             // In a real app with context, the redirect in App.jsx should handle this
             alert("Login successful (simulation). You would be redirected now.");
             // Replace alert with: navigate(from, { replace: true }); if NOT using context-based routing protection in App.jsx

        } catch (err) {
            setError(err.message || "Failed to log in.");
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="flex items-center justify-center min-h-screen bg-gradient-to-br from-blue-100 via-white to-purple-100">
            <div className="p-8 bg-white rounded-lg shadow-xl w-full max-w-sm">
                {/* Add logo maybe */}
                 <h1 className="text-3xl font-bold text-center text-blue-600 mb-8">School Portal</h1>

                <form onSubmit={handleSubmit} className="space-y-6">
                    <div className="relative">
                        <span className="absolute inset-y-0 left-0 flex items-center pl-3">
                            <User className="h-5 w-5 text-gray-400" aria-hidden="true" />
                        </span>
                        <input
                            type="text"
                            id="username"
                            placeholder="Username or Email"
                            value={username}
                            onChange={(e) => setUsername(e.target.value)}
                            required
                            className="pl-10 mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                        />
                    </div>
                    <div className="relative">
                         <span className="absolute inset-y-0 left-0 flex items-center pl-3">
                            <Lock className="h-5 w-5 text-gray-400" aria-hidden="true" />
                        </span>
                        <input
                            type="password"
                            id="password"
                            placeholder="Password"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            required
                            className="pl-10 mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                        />
                    </div>

                    {error && <ErrorMessage message={error} />}

                    <div>
                        <button
                            type="submit"
                            disabled={isLoading}
                            className="w-full flex justify-center py-3 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
                        >
                            {isLoading ? (
                                <div className="flex justify-center items-center h-5">
                                    <svg className="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                    </svg>
                                </div>
                            ) : 'Log In'}
                        </button>
                    </div>
                     {/* Add Forgot Password link if needed */}
                     {/* <div className="text-center text-sm">
                        <a href="#" className="font-medium text-blue-600 hover:text-blue-500">
                            Forgot your password?
                        </a>
                    </div> */}
                </form>
            </div>
        </div>
    );
}

export default LoginScreen;
