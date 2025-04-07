import React from 'react';
import { NavLink } from 'react-router-dom';
import { Home, Calendar, BookOpen, Award, User } from 'lucide-react';

function NavBar() {
  const navItems = [
    { path: "/home", icon: <Home size={20} />, label: "Home" },
    { path: "/events", icon: <Calendar size={20} />, label: "Events" },
    { path: "/athletics", icon: <Award size={20} />, label: "Athletics" },
    { path: "/grades", icon: <BookOpen size={20} />, label: "Grades" },
    { path: "/profile", icon: <User size={20} />, label: "My Info" },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 w-full bg-white border-t border-gray-200 shadow-sm z-10">
      <div className="grid grid-cols-5 h-16">
        {navItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            // Handle potential end matching issue for '/' vs '/home' if '/' is used
            end={item.path === '/home'}
            className={({ isActive }) =>
              `flex flex-col items-center justify-center focus:outline-none focus:ring-2 focus:ring-blue-300 ${isActive ? 'text-blue-500' : 'text-gray-500 hover:text-blue-400'}`
            }
          >
            {item.icon}
            <span className="text-xs mt-1 font-medium">{item.label}</span>
          </NavLink>
        ))}
      </div>
    </div>
  );
}

export default NavBar;
