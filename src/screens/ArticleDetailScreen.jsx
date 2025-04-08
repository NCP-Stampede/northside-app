import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { fetchArticleDetails } from '../services/api';
import LoadingSpinner from '../components/LoadingSpinner';
import ErrorMessage from '../components/ErrorMessage';
import { ChevronLeft } from 'lucide-react';

function ArticleDetailScreen() {
    const { articleSlug } = useParams();
    const navigate = useNavigate();
    const [article, setArticle] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);

    useEffect(() => {
        const loadData = async () => {
            setIsLoading(true); setError(null);
            try {
                const data = await fetchArticleDetails(articleSlug);
                setArticle(data);
            } catch (err) { setError(err.message || "Could not load article."); console.error(err); }
            finally { setIsLoading(false); }
        };
        loadData();
    }, [articleSlug]);

    return (
        <div className="p-4">
             <header className="flex items-center mb-4 -ml-1">
                <button onClick={() => navigate(-1)} className="p-1 rounded-full hover:bg-gray-200" aria-label="Go back">
                    <ChevronLeft size={24} className="text-blue-600" />
                </button>
                 <h1 className="text-xl font-bold ml-2 truncate">{article?.title || 'Article'}</h1>
            </header>

            {isLoading && <LoadingSpinner />}
            {error && <ErrorMessage message={error} />}

            {!isLoading && !error && article && (
                <div className="bg-white rounded-lg shadow overflow-hidden">
                    {article.image && (
                        <div className="w-full h-48 bg-gray-200">
                             <img src={article.image} alt="" className="w-full h-full object-cover"/>
                        </div>
                    )}
                    <div className="p-4">
                        <h1 className="text-2xl font-bold mb-2">{article.title}</h1>
                        <div className="text-xs text-gray-500 mb-4">
                            By {article.author || 'Staff'} {article.date && `• ${new Date(article.date).toLocaleDateString()}`}
                        </div>
                         {/* Render HTML content safely using Tailwind Typography plugin */}
                        <div className="prose prose-sm max-w-none" dangerouslySetInnerHTML={{ __html: article.content || '' }} />
                    </div>
                </div>
            )}
             {!isLoading && !error && !article && (
                 <p className="text-center text-gray-500 mt-8">Article not found.</p>
             )}
        </div>
    );
}

export default ArticleDetailScreen;
