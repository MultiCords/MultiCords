-- TBC Academy Two-Sided Educational Platform Migration
-- Schema Analysis: Existing user_profiles table with basic auth
-- Integration Type: Extension - Adding teacher/student functionality
-- Dependencies: user_profiles, auth.users

-- ============================================
-- 1. EXTEND USER_PROFILES FOR DUAL USER TYPES
-- ============================================

-- Add user type and role-specific fields
ALTER TABLE public.user_profiles
ADD COLUMN IF NOT EXISTS user_type TEXT CHECK (user_type IN ('student', 'teacher')) DEFAULT 'student',
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS qualifications TEXT,
ADD COLUMN IF NOT EXISTS expertise_areas TEXT[],
ADD COLUMN IF NOT EXISTS total_followers INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_content INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_earnings DECIMAL(10, 2) DEFAULT 0.00,
ADD COLUMN IF NOT EXISTS rating DECIMAL(3, 2) DEFAULT 0.00,
ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false;

-- Create index for user type queries
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_type ON public.user_profiles(user_type);
CREATE INDEX IF NOT EXISTS idx_user_profiles_rating ON public.user_profiles(rating DESC);

-- ============================================
-- 2. CREATE ENUM TYPES
-- ============================================

CREATE TYPE public.content_type AS ENUM ('video', 'notes', 'document', 'quiz', 'live_class');
CREATE TYPE public.content_status AS ENUM ('draft', 'published', 'archived');
CREATE TYPE public.subject_category AS ENUM ('neet_biology', 'neet_physics', 'neet_chemistry', 'computer_science', 'government_exam', 'engineering', 'other');
CREATE TYPE public.session_status AS ENUM ('scheduled', 'live', 'completed', 'cancelled');
CREATE TYPE public.payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
CREATE TYPE public.notification_type AS ENUM ('new_content', 'class_scheduled', 'class_reminder', 'follower_update', 'payment_received');

-- ============================================
-- 3. TEACHER CONTENT MANAGEMENT
-- ============================================

-- Main content table for teacher uploads
CREATE TABLE public.course_content (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  content_type public.content_type NOT NULL,
  subject_category public.subject_category NOT NULL,
  file_url TEXT,
  thumbnail_url TEXT,
  duration_minutes INTEGER,
  price DECIMAL(10, 2) DEFAULT 0.00,
  is_free BOOLEAN DEFAULT false,
  status public.content_status DEFAULT 'draft',
  views_count INTEGER DEFAULT 0,
  likes_count INTEGER DEFAULT 0,
  enrollment_count INTEGER DEFAULT 0,
  tags TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Content sections/chapters for organization
CREATE TABLE public.content_section (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_id UUID NOT NULL REFERENCES public.course_content(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  order_index INTEGER NOT NULL,
  duration_minutes INTEGER,
  is_preview BOOLEAN DEFAULT false,
  video_url TEXT,
  notes_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Content reviews and ratings
CREATE TABLE public.content_review (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_id UUID NOT NULL REFERENCES public.course_content(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review_text TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(content_id, student_id)
);

-- ============================================
-- 4. STUDENT ENROLLMENT & PROGRESS TRACKING
-- ============================================

-- Student content enrollments
CREATE TABLE public.student_enrollment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  content_id UUID NOT NULL REFERENCES public.course_content(id) ON DELETE CASCADE,
  enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  access_expires_at TIMESTAMP WITH TIME ZONE,
  progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  last_accessed_at TIMESTAMP WITH TIME ZONE,
  completed_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(student_id, content_id)
);

-- Track section completion
CREATE TABLE public.section_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  enrollment_id UUID NOT NULL REFERENCES public.student_enrollment(id) ON DELETE CASCADE,
  section_id UUID NOT NULL REFERENCES public.content_section(id) ON DELETE CASCADE,
  is_completed BOOLEAN DEFAULT false,
  watch_time_minutes INTEGER DEFAULT 0,
  completed_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(enrollment_id, section_id)
);

-- ============================================
-- 5. LIVE CLASS SESSIONS
-- ============================================

-- Teacher-conducted live classes
CREATE TABLE public.class_session (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  content_id UUID REFERENCES public.course_content(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT,
  subject_category public.subject_category NOT NULL,
  scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
  duration_minutes INTEGER DEFAULT 60,
  meeting_link TEXT,
  max_participants INTEGER,
  current_participants INTEGER DEFAULT 0,
  price DECIMAL(10, 2) DEFAULT 0.00,
  status public.session_status DEFAULT 'scheduled',
  recording_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Class session registrations
CREATE TABLE public.session_registration (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL REFERENCES public.class_session(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  registered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  attended BOOLEAN DEFAULT false,
  attended_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(session_id, student_id)
);

-- ============================================
-- 6. PAYMENT & TRANSACTION SYSTEM
-- ============================================

-- Transaction records for all payments
CREATE TABLE public.transaction_record (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  content_id UUID REFERENCES public.course_content(id) ON DELETE SET NULL,
  session_id UUID REFERENCES public.class_session(id) ON DELETE SET NULL,
  amount DECIMAL(10, 2) NOT NULL CHECK (amount > 0),
  platform_fee DECIMAL(10, 2) DEFAULT 0.00,
  teacher_earnings DECIMAL(10, 2) NOT NULL,
  payment_method TEXT,
  payment_status public.payment_status DEFAULT 'pending',
  transaction_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  payment_reference TEXT,
  CONSTRAINT content_or_session_required CHECK (
    (content_id IS NOT NULL AND session_id IS NULL) OR
    (content_id IS NULL AND session_id IS NOT NULL)
  )
);

-- ============================================
-- 7. FOLLOWER & NOTIFICATION SYSTEM
-- ============================================

-- Teacher followers (students following teachers)
CREATE TABLE public.teacher_follower (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  teacher_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  followed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  notifications_enabled BOOLEAN DEFAULT true,
  UNIQUE(student_id, teacher_id)
);

-- Notification system
CREATE TABLE public.user_notification (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  notification_type public.notification_type NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  related_id UUID,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- 8. CONTENT INTERACTION & ENGAGEMENT
-- ============================================

-- Content likes/favorites
CREATE TABLE public.content_like (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_id UUID NOT NULL REFERENCES public.course_content(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(content_id, user_id)
);

-- Content bookmarks/saved items
CREATE TABLE public.content_bookmark (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  content_id UUID NOT NULL REFERENCES public.course_content(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(content_id, student_id)
);

-- ============================================
-- 9. CREATE INDEXES FOR PERFORMANCE
-- ============================================

-- Content table indexes
CREATE INDEX idx_course_content_teacher ON public.course_content(teacher_id);
CREATE INDEX idx_course_content_subject ON public.course_content(subject_category);
CREATE INDEX idx_course_content_status ON public.course_content(status);
CREATE INDEX idx_course_content_created ON public.course_content(created_at DESC);
CREATE INDEX idx_course_content_price ON public.course_content(price);

-- Section indexes
CREATE INDEX idx_content_section_content ON public.content_section(content_id);
CREATE INDEX idx_content_section_order ON public.content_section(content_id, order_index);

-- Review indexes
CREATE INDEX idx_content_review_content ON public.content_review(content_id);
CREATE INDEX idx_content_review_student ON public.content_review(student_id);

-- Enrollment indexes
CREATE INDEX idx_enrollment_student ON public.student_enrollment(student_id);
CREATE INDEX idx_enrollment_content ON public.student_enrollment(content_id);
CREATE INDEX idx_enrollment_date ON public.student_enrollment(enrolled_at DESC);

-- Progress indexes
CREATE INDEX idx_section_progress_enrollment ON public.section_progress(enrollment_id);
CREATE INDEX idx_section_progress_section ON public.section_progress(section_id);

-- Class session indexes
CREATE INDEX idx_class_session_teacher ON public.class_session(teacher_id);
CREATE INDEX idx_class_session_subject ON public.class_session(subject_category);
CREATE INDEX idx_class_session_scheduled ON public.class_session(scheduled_at);
CREATE INDEX idx_class_session_status ON public.class_session(status);

-- Registration indexes
CREATE INDEX idx_session_registration_session ON public.session_registration(session_id);
CREATE INDEX idx_session_registration_student ON public.session_registration(student_id);

-- Transaction indexes
CREATE INDEX idx_transaction_student ON public.transaction_record(student_id);
CREATE INDEX idx_transaction_teacher ON public.transaction_record(teacher_id);
CREATE INDEX idx_transaction_date ON public.transaction_record(transaction_date DESC);
CREATE INDEX idx_transaction_status ON public.transaction_record(payment_status);

-- Follower indexes
CREATE INDEX idx_follower_student ON public.teacher_follower(student_id);
CREATE INDEX idx_follower_teacher ON public.teacher_follower(teacher_id);

-- Notification indexes
CREATE INDEX idx_notification_user ON public.user_notification(user_id);
CREATE INDEX idx_notification_read ON public.user_notification(user_id, is_read);
CREATE INDEX idx_notification_created ON public.user_notification(created_at DESC);

-- Like/bookmark indexes
CREATE INDEX idx_content_like_content ON public.content_like(content_id);
CREATE INDEX idx_content_like_user ON public.content_like(user_id);
CREATE INDEX idx_content_bookmark_content ON public.content_bookmark(content_id);
CREATE INDEX idx_content_bookmark_student ON public.content_bookmark(student_id);

-- ============================================
-- 10. HELPER FUNCTIONS
-- ============================================

-- Function to check if user is teacher
CREATE OR REPLACE FUNCTION public.is_teacher()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.user_type = 'teacher'
)
$$;

-- Function to check if user is student
CREATE OR REPLACE FUNCTION public.is_student()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.user_type = 'student'
)
$$;

-- Function to check if student has enrolled in content
CREATE OR REPLACE FUNCTION public.has_enrolled_in_content(content_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.student_enrollment se
    WHERE se.content_id = content_uuid AND se.student_id = auth.uid()
)
$$;

-- ============================================
-- 11. ENABLE ROW LEVEL SECURITY
-- ============================================

ALTER TABLE public.course_content ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_section ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_review ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_enrollment ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.section_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.class_session ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_registration ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transaction_record ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teacher_follower ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notification ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_like ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_bookmark ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 12. RLS POLICIES - COURSE CONTENT
-- ============================================

-- Teachers manage their own content
CREATE POLICY teacher_manage_own_content ON public.course_content
  FOR ALL
  TO authenticated
  USING (teacher_id = auth.uid())
  WITH CHECK (teacher_id = auth.uid());

-- Students/public view published content
CREATE POLICY public_view_published_content ON public.course_content
  FOR SELECT
  TO authenticated
  USING (status = 'published');

-- ============================================
-- 13. RLS POLICIES - CONTENT SECTIONS
-- ============================================

-- Teachers manage sections of their content
CREATE POLICY teacher_manage_own_sections ON public.content_section
  FOR ALL
  TO authenticated
  USING (
    content_id IN (
      SELECT id FROM public.course_content WHERE teacher_id = auth.uid()
    )
  );

-- Students view sections of enrolled or preview content
CREATE POLICY student_view_sections ON public.content_section
  FOR SELECT
  TO authenticated
  USING (
    is_preview = true OR
    content_id IN (
      SELECT content_id FROM public.student_enrollment WHERE student_id = auth.uid()
    )
  );

-- ============================================
-- 14. RLS POLICIES - REVIEWS
-- ============================================

-- Students manage their own reviews
CREATE POLICY student_manage_own_reviews ON public.content_review
  FOR ALL
  TO authenticated
  USING (student_id = auth.uid())
  WITH CHECK (student_id = auth.uid());

-- Anyone can view published reviews
CREATE POLICY public_view_reviews ON public.content_review
  FOR SELECT
  TO authenticated
  USING (true);

-- ============================================
-- 15. RLS POLICIES - ENROLLMENTS
-- ============================================

-- Students view their own enrollments
CREATE POLICY student_view_own_enrollments ON public.student_enrollment
  FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

-- Students create their own enrollments
CREATE POLICY student_create_enrollments ON public.student_enrollment
  FOR INSERT
  TO authenticated
  WITH CHECK (student_id = auth.uid());

-- Teachers view enrollments for their content
CREATE POLICY teacher_view_content_enrollments ON public.student_enrollment
  FOR SELECT
  TO authenticated
  USING (
    content_id IN (
      SELECT id FROM public.course_content WHERE teacher_id = auth.uid()
    )
  );

-- ============================================
-- 16. RLS POLICIES - SECTION PROGRESS
-- ============================================

-- Students manage their own progress
CREATE POLICY student_manage_own_progress ON public.section_progress
  FOR ALL
  TO authenticated
  USING (
    enrollment_id IN (
      SELECT id FROM public.student_enrollment WHERE student_id = auth.uid()
    )
  )
  WITH CHECK (
    enrollment_id IN (
      SELECT id FROM public.student_enrollment WHERE student_id = auth.uid()
    )
  );

-- ============================================
-- 17. RLS POLICIES - CLASS SESSIONS
-- ============================================

-- Teachers manage their own sessions
CREATE POLICY teacher_manage_own_sessions ON public.class_session
  FOR ALL
  TO authenticated
  USING (teacher_id = auth.uid())
  WITH CHECK (teacher_id = auth.uid());

-- Students view scheduled/live sessions
CREATE POLICY student_view_sessions ON public.class_session
  FOR SELECT
  TO authenticated
  USING (status IN ('scheduled', 'live'));

-- ============================================
-- 18. RLS POLICIES - SESSION REGISTRATIONS
-- ============================================

-- Students manage their own registrations
CREATE POLICY student_manage_own_registrations ON public.session_registration
  FOR ALL
  TO authenticated
  USING (student_id = auth.uid())
  WITH CHECK (student_id = auth.uid());

-- Teachers view registrations for their sessions
CREATE POLICY teacher_view_session_registrations ON public.session_registration
  FOR SELECT
  TO authenticated
  USING (
    session_id IN (
      SELECT id FROM public.class_session WHERE teacher_id = auth.uid()
    )
  );

-- ============================================
-- 19. RLS POLICIES - TRANSACTIONS
-- ============================================

-- Students view their own transactions
CREATE POLICY student_view_own_transactions ON public.transaction_record
  FOR SELECT
  TO authenticated
  USING (student_id = auth.uid());

-- Teachers view their earnings
CREATE POLICY teacher_view_own_earnings ON public.transaction_record
  FOR SELECT
  TO authenticated
  USING (teacher_id = auth.uid());

-- ============================================
-- 20. RLS POLICIES - FOLLOWERS
-- ============================================

-- Students manage their own follows
CREATE POLICY student_manage_own_follows ON public.teacher_follower
  FOR ALL
  TO authenticated
  USING (student_id = auth.uid())
  WITH CHECK (student_id = auth.uid());

-- Teachers view their followers
CREATE POLICY teacher_view_own_followers ON public.teacher_follower
  FOR SELECT
  TO authenticated
  USING (teacher_id = auth.uid());

-- ============================================
-- 21. RLS POLICIES - NOTIFICATIONS
-- ============================================

-- Users manage their own notifications
CREATE POLICY users_manage_own_notifications ON public.user_notification
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ============================================
-- 22. RLS POLICIES - LIKES & BOOKMARKS
-- ============================================

-- Users manage their own likes
CREATE POLICY users_manage_own_likes ON public.content_like
  FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Anyone can view like counts (aggregated)
CREATE POLICY public_view_likes ON public.content_like
  FOR SELECT
  TO authenticated
  USING (true);

-- Students manage their own bookmarks
CREATE POLICY student_manage_own_bookmarks ON public.content_bookmark
  FOR ALL
  TO authenticated
  USING (student_id = auth.uid())
  WITH CHECK (student_id = auth.uid());

-- ============================================
-- 23. TRIGGERS FOR AUTO-UPDATES
-- ============================================

-- Update timestamp triggers
CREATE TRIGGER update_course_content_timestamp
  BEFORE UPDATE ON public.course_content
  FOR EACH ROW
  EXECUTE FUNCTION update_user_profile_timestamp();

-- Update follower count when following/unfollowing
CREATE OR REPLACE FUNCTION public.update_teacher_follower_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.user_profiles 
    SET total_followers = total_followers + 1
    WHERE id = NEW.teacher_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.user_profiles 
    SET total_followers = GREATEST(0, total_followers - 1)
    WHERE id = OLD.teacher_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER update_follower_count_trigger
  AFTER INSERT OR DELETE ON public.teacher_follower
  FOR EACH ROW
  EXECUTE FUNCTION update_teacher_follower_count();

-- Update content count when creating/deleting content
CREATE OR REPLACE FUNCTION public.update_teacher_content_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.user_profiles 
    SET total_content = total_content + 1
    WHERE id = NEW.teacher_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.user_profiles 
    SET total_content = GREATEST(0, total_content - 1)
    WHERE id = OLD.teacher_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER update_content_count_trigger
  AFTER INSERT OR DELETE ON public.course_content
  FOR EACH ROW
  EXECUTE FUNCTION update_teacher_content_count();

-- Update enrollment count
CREATE OR REPLACE FUNCTION public.update_content_enrollment_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.course_content 
    SET enrollment_count = enrollment_count + 1
    WHERE id = NEW.content_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.course_content 
    SET enrollment_count = GREATEST(0, enrollment_count - 1)
    WHERE id = OLD.content_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER update_enrollment_count_trigger
  AFTER INSERT OR DELETE ON public.student_enrollment
  FOR EACH ROW
  EXECUTE FUNCTION update_content_enrollment_count();

-- Update likes count
CREATE OR REPLACE FUNCTION public.update_content_likes_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.course_content 
    SET likes_count = likes_count + 1
    WHERE id = NEW.content_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.course_content 
    SET likes_count = GREATEST(0, likes_count - 1)
    WHERE id = OLD.content_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER update_likes_count_trigger
  AFTER INSERT OR DELETE ON public.content_like
  FOR EACH ROW
  EXECUTE FUNCTION update_content_likes_count();

-- Update class session participant count
CREATE OR REPLACE FUNCTION public.update_session_participant_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.class_session 
    SET current_participants = current_participants + 1
    WHERE id = NEW.session_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.class_session 
    SET current_participants = GREATEST(0, current_participants - 1)
    WHERE id = OLD.session_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER update_participant_count_trigger
  AFTER INSERT OR DELETE ON public.session_registration
  FOR EACH ROW
  EXECUTE FUNCTION update_session_participant_count();

-- Update teacher earnings on completed transaction
CREATE OR REPLACE FUNCTION public.update_teacher_earnings()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NEW.payment_status = 'completed' AND (OLD.payment_status IS NULL OR OLD.payment_status != 'completed') THEN
    UPDATE public.user_profiles 
    SET total_earnings = total_earnings + NEW.teacher_earnings
    WHERE id = NEW.teacher_id;
  END IF;
  RETURN NULL;
END;
$$;

CREATE TRIGGER update_earnings_trigger
  AFTER INSERT OR UPDATE ON public.transaction_record
  FOR EACH ROW
  EXECUTE FUNCTION update_teacher_earnings();

-- ============================================
-- 24. VIEWS FOR ANALYTICS
-- ============================================

-- Teacher dashboard analytics view
CREATE OR REPLACE VIEW public.teacher_analytics AS
SELECT 
  up.id AS teacher_id,
  up.full_name,
  up.total_followers,
  up.total_content,
  up.total_earnings,
  up.rating,
  COUNT(DISTINCT cc.id) AS published_content_count,
  COUNT(DISTINCT se.id) AS total_enrollments,
  COUNT(DISTINCT cs.id) AS total_sessions,
  COALESCE(SUM(cc.views_count), 0) AS total_views,
  COALESCE(SUM(cc.likes_count), 0) AS total_likes
FROM public.user_profiles up
LEFT JOIN public.course_content cc ON up.id = cc.teacher_id AND cc.status = 'published'
LEFT JOIN public.student_enrollment se ON cc.id = se.content_id
LEFT JOIN public.class_session cs ON up.id = cs.teacher_id
WHERE up.user_type = 'teacher'
GROUP BY up.id, up.full_name, up.total_followers, up.total_content, up.total_earnings, up.rating;

-- Student learning analytics view
CREATE OR REPLACE VIEW public.student_analytics AS
SELECT 
  up.id AS student_id,
  up.full_name,
  COUNT(DISTINCT se.id) AS enrolled_courses,
  COUNT(DISTINCT tf.id) AS following_teachers,
  COUNT(DISTINCT sr.id) AS registered_sessions,
  COALESCE(AVG(se.progress_percentage), 0) AS avg_progress,
  COUNT(DISTINCT CASE WHEN se.completed_at IS NOT NULL THEN se.id END) AS completed_courses
FROM public.user_profiles up
LEFT JOIN public.student_enrollment se ON up.id = se.student_id
LEFT JOIN public.teacher_follower tf ON up.id = tf.student_id
LEFT JOIN public.session_registration sr ON up.id = sr.student_id
WHERE up.user_type = 'student'
GROUP BY up.id, up.full_name;

-- Popular content view
CREATE OR REPLACE VIEW public.popular_content AS
SELECT 
  cc.id,
  cc.title,
  cc.subject_category,
  cc.content_type,
  cc.price,
  cc.enrollment_count,
  cc.views_count,
  cc.likes_count,
  up.full_name AS teacher_name,
  COALESCE(AVG(cr.rating), 0) AS avg_rating,
  COUNT(DISTINCT cr.id) AS review_count
FROM public.course_content cc
JOIN public.user_profiles up ON cc.teacher_id = up.id
LEFT JOIN public.content_review cr ON cc.id = cr.content_id
WHERE cc.status = 'published'
GROUP BY cc.id, cc.title, cc.subject_category, cc.content_type, cc.price, 
         cc.enrollment_count, cc.views_count, cc.likes_count, up.full_name
ORDER BY cc.enrollment_count DESC, cc.likes_count DESC;