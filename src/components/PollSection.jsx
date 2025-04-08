import React, { useState } from 'react';

// Optional: Extracted Poll UI - State management is local here for demo
function PollSection() {
    const [selectedOption, setSelectedOption] = useState(null);
    const [submitted, setSubmitted] = useState(false);

    const handleSelect = (option) => {
        if (submitted) return;
        setSelectedOption(option);
    };

    const handleSubmit = () => {
        if (!selectedOption) return;
        console.log("Poll submitted:", selectedOption); // Replace with actual submission logic
        setSubmitted(true);
        // Add logic to show results maybe
    };

    return (
        <div className="bg-white rounded-xl shadow-sm p-4">
            <h3 className="font-medium mb-3 text-center">Do You Have Senioritis?</h3>
            <div className="space-y-2">
                {['Yes', 'No', 'Maybe'].map((option) => (
                    <button
                        key={option}
                        onClick={() => handleSelect(option)}
                        disabled={submitted}
                        className={`w-full text-left p-2 border rounded transition duration-150 disabled:opacity-70 ${
                            selectedOption === option
                                ? 'border-blue-500 bg-blue-50 ring-1 ring-blue-500'
                                : 'border-gray-200 hover:bg-gray-100'
                            }`}
                    >
                        {option}
                    </button>
                ))}
            </div>
            {!submitted && (
                <button
                    onClick={handleSubmit}
                    disabled={!selectedOption}
                    className="mt-4 w-full bg-blue-600 text-white py-2 rounded hover:bg-blue-700 disabled:opacity-50"
                >
                    Submit Vote
                </button>
            )}
            {submitted && (
                 <p className="text-center text-green-600 mt-3 text-sm font-medium">Thanks for voting!</p>
            )}
        </div>
    );
}
export default PollSection;
