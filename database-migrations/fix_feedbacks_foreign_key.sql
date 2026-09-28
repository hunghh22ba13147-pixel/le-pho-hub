-- Fix feedbacks foreign key to reference profiles instead of auth.users
-- This allows proper joining with profiles table to get user name and role

-- Step 1: Drop old constraint
ALTER TABLE public.feedbacks 
DROP CONSTRAINT IF EXISTS feedbacks_user_id_fkey;

-- Step 2: Add new constraint pointing to profiles
ALTER TABLE public.feedbacks 
ADD CONSTRAINT feedbacks_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- Done! Now queries can properly join feedbacks with profiles table

