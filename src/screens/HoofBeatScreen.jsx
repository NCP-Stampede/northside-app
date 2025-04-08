import React, { useState, useEffect } from 'react';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import FeaturedStoryCard from '../components/FeaturedStoryCard';
import TrendingStoryCard from '../components/TrendingStoryCard';
import NewsItem from '../components/NewsItem';
import PollSection from '../components/PollSection'; // Import Poll section
import { fetchHoofbeat } from '../services/api';

function HoofBeatScreen() {
    const [hoofbeatData, setHoofbeatData] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);

     useEffect(() => {
        const loadData = async () => {
            setIsLoading(true); setError(null);
            try {
                const data = await fetchHoofbeat();
                setHoofbeatData(data);
            } catch (err) { setError("Failed to load HoofBeat content."); console.error(err); }
            finally { setIsLoading(false); }
        };
        loadData();
    }, []);

  return (
    <div className="p-4">
      <header className="mb-6">
        <h1 className="text-2xl font-bold">HoofBeat</h1>
        <div className="text-sm text-gray-500">Campus Insights & News</div>
      </header>

        {isLoading && <LoadingSpinner />}
        {error && <ErrorMessage message={error} />}

        {!isLoading && !error && hoofbeatData && (
            <>
                 {/* Featured Headline */}
                 {hoofbeatData.headline && <FeaturedStoryCard {...hoofbeatData.headline} slug={hoofbeatData.headline.slug} />}

                {/* Trending Stories */}
                 {hoofbeatData.trending?.length > 0 && (
                     <>
                        <h2 className="text-lg font-semibold mb-3">Trending Stories</h2>
                        <div className="grid grid-cols-3 gap-3 mb-6">
                            {hoofbeatData.trending.map(story => (
                                <TrendingStoryCard key={story.id} {...story} slug={story.slug} />
                            ))}
                        </div>
                    </>
                 )}

                {/* News */}
                {hoofbeatData.news?.length > 0 && (
                    <>
                        <h2 className="text-lg font-semibold mb-3">News</h2>
                        <div className="space-y-3 mb-6">
                            {hoofbeatData.news.map(item => (
                                <NewsItem key={item.id} {...item} slug={item.slug} />
                            ))}
                        </div>
                    </>
                )}

                {/* Polls Section */}
                <h2 className="text-lg font-semibold mb-3">Polls</h2>
                <PollSection /> {/* Use the extracted component */}

            </>
        )}
        {!isLoading && !error && !hoofbeatData && (
            <p className="text-center text-gray-500 mt-8">Could not load HoofBeat content.</p>
        )}
    </div>
  );
}
export default HoofBeatScreen;
