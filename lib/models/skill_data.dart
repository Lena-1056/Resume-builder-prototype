// Predefined skill categories for the selection UI.
class SkillData {
  static const Map<String, List<String>> skillsByCategory = {
    'Frontend': [
      'HTML', 'CSS', 'JavaScript', 'TypeScript', 'React', 'Angular',
      'Vue.js', 'Next.js', 'Svelte', 'Tailwind CSS', 'Bootstrap',
      'Redux', 'Webpack', 'Responsive Design', 'SASS/SCSS',
    ],
    'Backend': [
      'Python', 'Java', 'Node.js', 'C#', 'Go', 'Ruby',
      'FastAPI', 'Django', 'Flask', 'Spring Boot', 'Express.js',
      'REST API', 'GraphQL', 'gRPC', 'Microservices',
    ],
    'DevOps': [
      'Docker', 'Kubernetes', 'AWS', 'Azure', 'GCP',
      'CI/CD', 'Jenkins', 'GitHub Actions', 'Terraform',
      'Ansible', 'Linux', 'Nginx', 'Monitoring', 'Prometheus',
    ],
    'Data & AI': [
      'SQL', 'PostgreSQL', 'MongoDB', 'Redis', 'Elasticsearch',
      'Machine Learning', 'Deep Learning', 'TensorFlow', 'PyTorch',
      'Pandas', 'NumPy', 'Data Analysis', 'NLP', 'Computer Vision',
    ],
    'Mobile': [
      'Flutter', 'Dart', 'React Native', 'Swift', 'Kotlin',
      'Android', 'iOS', 'Firebase', 'Mobile UI/UX',
    ],
    'Tools & Others': [
      'Git', 'GitHub', 'Jira', 'Agile/Scrum', 'Figma',
      'Postman', 'VS Code', 'Unit Testing', 'System Design',
      'Problem Solving', 'Communication',
    ],
  };
}
