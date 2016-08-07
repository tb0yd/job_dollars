Gem::Specification.new do |s|
  s.name        = 'job_dollars'
  s.version     = '1.0.5'
  s.licenses    = ['MIT']
  s.summary     = "An economic measure of the value of a programming language and framework."
  s.description = "A job dollar is an objective measure of the strength of the job market for entry-level workers using a given programming language and framework. It is a composite measure of work, like kilowatt-hours or Joules, and it measures how much work the market has done for you."
  s.authors     = ["Tyler Boyd"]
  s.email       = 'tboyd47@gmail.com'
  s.files            = `git ls-files -- lib/*`.split("\n")
  s.require_paths    = ["lib"]
  s.rdoc_options += ['-x', 'lib/job_dollars/core_ext/*', '-m', 'README.md']
  s.homepage    = 'https://www.github.com/tb0yd/job_dollars'
end
