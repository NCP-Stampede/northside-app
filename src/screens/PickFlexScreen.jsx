import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { fetchFlexOptions, registerForFlex } from '../services/api';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import { ChevronLeft, Check } from 'lucide-react';

function PickFlexScreen() {
    const { flexId } = useParams();
    const navigate = useNavigate();
    const [flexInfo, setFlexInfo] = useState({ name: '', options: [], status: 'loading' });
    const [selectedOptionId, setSelectedOptionId] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [error, setError] = useState(null);
    const [submitSuccess, setSubmitSuccess] = useState(null);

    useEffect(() => {
        const loadData = async () => {
            setIsLoading(true);
            setError(null);
             setSubmitSuccess(null); // Reset success message on load
            try {
                const data = await fetchFlexOptions(flexId);
                setFlexInfo(data);
                // TODO: Pre-select if already registered (Needs API to return current registration)
            } catch (err) {
                setError('Failed to load Flex options.');
                console.error(err);
                setFlexInfo({ name: 'Flex', options: [], status: 'error' }); // Update status on error
            } finally {
                setIsLoading(false);
            }
        };
        loadData();
    }, [flexId]);

    const handleSelect = (optionId) => {
         if (isSubmitting || submitSuccess) return; // Don't allow change after success/during submit
        setSelectedOptionId(optionId);
        setError(null); // Clear selection error
    };

    const handleSubmit = async () => {
        if (!selectedOptionId) {
            setError("Please select an option before submitting.");
            return;
        }
        setIsSubmitting(true);
        setError(null);
        setSubmitSuccess(null);
        try {
            const result = await registerForFlex(flexId, selectedOptionId);
            setSubmitSuccess(result.message || "Registration successful!");
            // Optional: navigate away after a delay
            // setTimeout(() => navigate('/flexes'), 2000);
        } catch (err) {
            setError(err.message || "Registration failed. Please try again.");
        } finally {
            setIsSubmitting(false);
        }
    };

    const canSelect = flexInfo.status === 'available';

    return (
        // Use min-h-screen and flex-col to push button down if content is short
        <div className="p-4 flex flex-col min-h-screen">
             <header className="flex items-center mb-4 -ml-1">
                <button onClick={() => navigate(-1)} className="p-1 rounded-full hover:bg-gray-200" disabled={isSubmitting} aria-label="Go back">
                    <ChevronLeft size={24} className="text-blue-600" />
                </button>
                <h1 className="text-xl font-bold ml-2">{flexInfo?.name || 'Select Flex Option'}</h1>
            </header>

            {isLoading && <div className="flex-grow flex items-center justify-center"><LoadingSpinner /></div>}
            {!isLoading && error && !submitSuccess && <div className="mb-4"><ErrorMessage message={error} /></div>}
            {submitSuccess && <div className="bg-green-100 text-green-700 p-3 rounded-lg mb-4 text-center font-medium">{submitSuccess}</div>}


            {!isLoading && flexInfo.status !== 'error' && (
                <div className="space-y-3 flex-grow">
                     {flexInfo.options.length > 0 ? (
                        flexInfo.options.map(option => (
                            <div
                                key={option.id}
                                onClick={() => canSelect && handleSelect(option.id)} // Only allow select if available
                                className={`border rounded-lg p-3 flex items-center justify-between transition-all ${
                                    !canSelect ? 'opacity-60 cursor-not-allowed bg-gray-50' :
                                    selectedOptionId === option.id
                                        ? 'border-blue-500 bg-blue-50 ring-1 ring-blue-500'
                                        : 'border-gray-300 bg-white hover:bg-gray-50 cursor-pointer'
                                } ${submitSuccess || isSubmitting ? 'opacity-70 cursor-not-allowed' : ''}`}
                            >
                                <div>
                                    <h3 className="font-medium">{option.title}</h3>
                                    <p className="text-xs text-gray-500">{option.room} • {option.teacher}</p>
                                </div>
                                {/* Radio button visual */}
                                <div className={`w-5 h-5 rounded-full border-2 flex items-center justify-center flex-shrink-0 ${
                                    selectedOptionId === option.id ? 'border-blue-500 bg-blue-500' : 'border-gray-400 bg-white'
                                }`}>
                                    {selectedOptionId === option.id && <Check size={12} className="text-white" />}
                                </div>
                            </div>
                        ))
                     ) : (
                        <p className="text-center text-gray-500 mt-8">
                            {flexInfo.status === 'upcoming' ? 'Options for this Flex period will be available soon.' : 'No options available for this Flex period.'}
                        </p>
                     )}
                </div>
             )}


             {/* Submit Button - appears at bottom */}
             {!isLoading && canSelect && flexInfo.options.length > 0 && !submitSuccess && (
                 <div className="mt-auto pt-6 border-t border-gray-200"> {/* mt-auto pushes to bottom */}
                     <button
                         onClick={handleSubmit}
                         disabled={!selectedOptionId || isSubmitting}
                         className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg transition duration-150 ease-in-out disabled:opacity-50 disabled:cursor-not-allowed"
                     >
                         {isSubmitting ? (
                             <div className="flex justify-center items-center">
                                 <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                </svg>
                                Submitting...
                            </div>
                         ) : 'Submit Selection'}
                     </button>
                 </div>
             )}
        </div>
    );
}
export default PickFlexScreen;
