# Database Integration - Supabase

This document explains how the fake data has been replaced with real Supabase database integration.

## Changes Made

### 1. Created Supabase Service Layer
- **File**: `src/lib/supabaseServices.ts`
- **Purpose**: Contains all database query functions and data transformation logic
- **Key Functions**:
  - `fetchRooms(limit?)`: Fetch all available rooms
  - `fetchRoomById(roomId)`: Fetch a single room by ID
  - `fetchRoomsWithFilters(filters)`: Fetch rooms with various filters
  - `transformRoomToStayData()`: Transform database data to frontend format

### 2. Updated Stay Listing Components
- **File**: `src/app/(stay-listings)/SectionGridFilterCard.tsx`
  - Replaced fake data with real database calls
  - Added loading states and error handling
  - Added empty state when no rooms are found

- **File**: `src/app/(stay-listings)/SectionGridHasMap.tsx`
  - Replaced fake data with real database calls
  - Updated map center to use real room coordinates
  - Added loading skeletons

### 3. Created API Route
- **File**: `src/app/api/rooms/route.ts`
- **Purpose**: REST API endpoint for room data
- **Endpoint**: `GET /api/rooms`
- **Query Parameters**:
  - `limit`: Number of rooms to fetch
  - `city`: Filter by city
  - `district`: Filter by district
  - `minPrice`, `maxPrice`: Price range filter
  - `minArea`, `maxArea`: Area range filter

### 4. Database Schema Integration
The service layer maps your Supabase database schema to the frontend data structure:

#### Database Tables Used:
- `rooms`: Main room data
- `profiles`: Owner information
- `room_images`: Room gallery images
- `reviews`: Room ratings and reviews
- `amenities` & `room_amenities`: Room amenities
- `surroundings` & `room_surroundings`: Nearby facilities
- `targets` & `room_targets`: Target audience

#### Data Transformation:
- Database `rooms` → Frontend `StayDataType`
- Database `profiles` → Frontend `AuthorType`
- Automatic price formatting to Vietnamese Dong
- Coordinate parsing for Google Maps
- Image gallery handling with fallbacks

## Setup Instructions

### 1. Environment Variables
Create a `.env.local` file in the project root:

```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
```

### 2. Database Requirements
Your Supabase database should have:
- All tables created as per your schema
- Row Level Security (RLS) policies configured
- Sample data in the `rooms` table with status='available'
- Related data in `profiles`, `room_images`, etc.

### 3. Testing
1. Start the development server: `npm run dev`
2. Visit `/phong-tro` or `/phong-tro-map`
3. Check the API endpoint: `http://localhost:3000/api/rooms`

## Features

### Frontend Features:
- ✅ Real-time data loading from Supabase
- ✅ Loading states with skeleton UI
- ✅ Error handling and empty states
- ✅ Vietnamese price formatting
- ✅ Google Maps integration with real coordinates
- ✅ Image gallery with fallback images
- ✅ Responsive design maintained

### Backend Features:
- ✅ Efficient database queries with joins
- ✅ Data transformation layer
- ✅ Filter support (city, district, price, area)
- ✅ Pagination support
- ✅ Error handling and logging
- ✅ TypeScript support throughout

### Default Fallbacks:
- **Images**: Unsplash placeholder images
- **Coordinates**: Ho Chi Minh City center (10.8231, 106.6297)
- **Avatars**: Professional placeholder from Unsplash
- **Reviews**: Default 4.5 rating if no reviews

## Migration Notes

### Removed Files/Dependencies:
- No longer using `DEMO_STAY_LISTINGS` from `/data/listings`
- No longer using `loadDbDemoListings()` from `/data/listingsFromDbDemo`
- Fake JSON data replaced with live database queries

### Maintained Compatibility:
- All existing component props and interfaces preserved
- Same URL structure and routing
- Same UI/UX experience
- Same responsive design

## Performance Considerations

1. **Database Queries**: Optimized with proper joins and indexing
2. **Image Loading**: Uses external CDN (Unsplash) for fallbacks
3. **Caching**: Consider adding React Query or SWR for client-side caching
4. **Pagination**: Implemented limit parameter for large datasets

## Troubleshooting

### Common Issues:
1. **No data showing**: Check Supabase credentials in `.env.local`
2. **Images not loading**: Verify `room_images` table has valid URLs
3. **Map not centering**: Check `maps` field format in rooms table
4. **TypeScript errors**: Run `npm run type-check`

### Debug Steps:
1. Check browser console for errors
2. Verify API endpoint: `GET /api/rooms`
3. Check Supabase dashboard for data
4. Verify RLS policies allow read access
