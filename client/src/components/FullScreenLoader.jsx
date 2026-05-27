import React from 'react';
import { Loader2 } from 'lucide-react';

const FullScreenLoader = ({ isVisible, text = 'Loading...' }) => {
    if (!isVisible) return null;

    return (
        <div className="fixed inset-0 z-[250] flex items-center justify-center">
            <div className="absolute inset-0 bg-slate-900/10 backdrop-blur-[2px]"></div>
            <div className="relative bg-white p-8 rounded-[2.5rem] shadow-2xl flex flex-col items-center justify-center border border-slate-100 animate-in fade-in zoom-in duration-200">
                <Loader2 className="w-8 h-8 text-indigo-600 animate-spin" />
                <p className="mt-4 font-black text-slate-700 uppercase tracking-widest text-[10px]">
                    {text}
                </p>
            </div>
        </div>
    );
};

export default FullScreenLoader;
