-- =============================================================================
-- Migration: AI Q&A and NEET Planner Features
-- Purpose: Add tables for student questions, AI responses, and personalized study plans
-- Author: TBC Academy Developer
-- Date: 2025-12-14
-- =============================================================================

-- =============================================================================
-- 1. STUDENT QUESTIONS TABLE
-- Purpose: Store student questions for AI-powered Q&A system
-- =============================================================================

CREATE TABLE IF NOT EXISTS student_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  subject_category subject_category NOT NULL,
  context_info JSONB, -- Additional context like related topic, difficulty level
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for efficient querying
CREATE INDEX idx_student_questions_student ON student_questions(student_id);
CREATE INDEX idx_student_questions_subject ON student_questions(subject_category);
CREATE INDEX idx_student_questions_created ON student_questions(created_at DESC);

-- =============================================================================
-- 2. AI RESPONSES TABLE
-- Purpose: Store AI-generated responses to student questions
-- =============================================================================

CREATE TABLE IF NOT EXISTS ai_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES student_questions(id) ON DELETE CASCADE,
  response_text TEXT NOT NULL,
  ai_model VARCHAR(100) NOT NULL, -- e.g., 'gpt-5-mini', 'gpt-5'
  confidence_score NUMERIC(3,2) CHECK (confidence_score >= 0 AND confidence_score <= 1),
  sources JSONB, -- Reference materials, video links, notes used
  is_helpful BOOLEAN DEFAULT NULL, -- Student feedback
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for efficient querying
CREATE INDEX idx_ai_responses_question ON ai_responses(question_id);
CREATE INDEX idx_ai_responses_created ON ai_responses(created_at DESC);

-- =============================================================================
-- 3. NEET STUDY PLANNER TABLE
-- Purpose: Store personalized AI-generated NEET preparation plans
-- =============================================================================

CREATE TABLE IF NOT EXISTS neet_study_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  plan_name VARCHAR(200) NOT NULL,
  target_exam_date DATE NOT NULL,
  current_preparation_level VARCHAR(50), -- 'beginner', 'intermediate', 'advanced'
  weak_subjects JSONB NOT NULL, -- Array of subjects needing focus
  strong_subjects JSONB, -- Array of subjects student is confident in
  daily_study_hours INTEGER CHECK (daily_study_hours > 0 AND daily_study_hours <= 24),
  preferences JSONB, -- Study preferences, learning style, etc.
  ai_recommendations TEXT NOT NULL, -- AI-generated plan details
  plan_structure JSONB NOT NULL, -- Weekly/daily breakdown of topics
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT TRUE
);

-- Indexes for efficient querying
CREATE INDEX idx_neet_plans_student ON neet_study_plans(student_id);
CREATE INDEX idx_neet_plans_active ON neet_study_plans(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_neet_plans_exam_date ON neet_study_plans(target_exam_date);

-- =============================================================================
-- 4. PLAN PROGRESS TRACKING TABLE
-- Purpose: Track student's progress against their NEET study plan
-- =============================================================================

CREATE TABLE IF NOT EXISTS plan_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID NOT NULL REFERENCES neet_study_plans(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  topics_completed JSONB NOT NULL, -- Array of completed topics for the day
  study_hours NUMERIC(4,2), -- Actual hours studied
  performance_score NUMERIC(5,2), -- Score from practice tests/quizzes
  notes TEXT, -- Student's personal notes
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(plan_id, date)
);

-- Indexes for efficient querying
CREATE INDEX idx_plan_progress_plan ON plan_progress(plan_id);
CREATE INDEX idx_plan_progress_date ON plan_progress(date DESC);

-- =============================================================================
-- 5. USER SESSION CACHE TABLE
-- Purpose: Store user authentication sessions for faster login
-- =============================================================================

CREATE TABLE IF NOT EXISTS user_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  session_token TEXT NOT NULL UNIQUE,
  device_info JSONB, -- Device type, OS, browser info
  last_accessed TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT valid_expiration CHECK (expires_at > created_at)
);

-- Indexes for efficient querying
CREATE INDEX idx_user_sessions_user ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON user_sessions(session_token);
CREATE INDEX idx_user_sessions_expires ON user_sessions(expires_at);

-- =============================================================================
-- 6. ROW LEVEL SECURITY POLICIES
-- Purpose: Ensure users can only access their own data
-- =============================================================================

-- Enable RLS on all new tables
ALTER TABLE student_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE neet_study_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE plan_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_sessions ENABLE ROW LEVEL SECURITY;

-- Student Questions Policies
CREATE POLICY student_manage_own_questions ON student_questions
  FOR ALL TO authenticated
  USING (student_id = auth.uid())
  WITH CHECK (student_id = auth.uid());

-- AI Responses Policies (students can view responses to their questions)
CREATE POLICY student_view_own_responses ON ai_responses
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM student_questions sq 
      WHERE sq.id = ai_responses.question_id 
      AND sq.student_id = auth.uid()
    )
  );

-- NEET Study Plans Policies
CREATE POLICY student_manage_own_plans ON neet_study_plans
  FOR ALL TO authenticated
  USING (student_id = auth.uid())
  WITH CHECK (student_id = auth.uid());

-- Plan Progress Policies
CREATE POLICY student_manage_own_progress ON plan_progress
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM neet_study_plans nsp 
      WHERE nsp.id = plan_progress.plan_id 
      AND nsp.student_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM neet_study_plans nsp 
      WHERE nsp.id = plan_progress.plan_id 
      AND nsp.student_id = auth.uid()
    )
  );

-- User Sessions Policies
CREATE POLICY user_manage_own_sessions ON user_sessions
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- =============================================================================
-- 7. TRIGGERS FOR AUTOMATIC TIMESTAMP UPDATES
-- Purpose: Automatically update updated_at timestamps
-- =============================================================================

CREATE TRIGGER update_student_questions_timestamp
  BEFORE UPDATE ON student_questions
  FOR EACH ROW
  EXECUTE FUNCTION update_user_profile_timestamp();

CREATE TRIGGER update_neet_plans_timestamp
  BEFORE UPDATE ON neet_study_plans
  FOR EACH ROW
  EXECUTE FUNCTION update_user_profile_timestamp();

-- =============================================================================
-- 8. CLEANUP FUNCTION FOR EXPIRED SESSIONS
-- Purpose: Remove expired sessions to maintain performance
-- =============================================================================

CREATE OR REPLACE FUNCTION cleanup_expired_sessions()
RETURNS void AS $$
BEGIN
  DELETE FROM user_sessions WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================================================
-- MIGRATION COMPLETE
-- =============================================================================