# job_dollars

The Ruby library for computing job-dollars, a measure of job market vitality.

### Explanation

I wanted an intuitive and objective measure for comparing programming languages and frameworks from the perspective of someone who knows nothing about programming, so I came up with job-dollars.

### Installation

`gem install job_dollars`

### Documentation

Check the [RDoc](http://www.rubydoc.info/gems/job_dollars/1.0.5/JobDollars)

### Usage

`job_dollars` supports a robust API for computing job-dollars, Javagrads, and some intermediate values:

```
applicants_per_job_distribution(total_resumes) ⇒ Hash<Fixnum, Float>
average_salary_from_indeed_facets(salatext, total) ⇒ Float
beginner_javagrad_rating(hash) ⇒ Float
chance_of_getting_job(years, total_resumes, type = :senior) ⇒ Float
crunch_salaries(hash) ⇒ Hash<Symbol, Float>
market_work_in_javagrads(y, hash) ⇒ Float
market_work_in_job_dollars(y, hash) ⇒ Float
to_javagrads(job_dollars) ⇒ Float
value_of_resume_item_in_dollars(y, hash) ⇒ Float
```

To get access to all of these methods in an IRB session, just require and include the `JobDollars` module:

```
require 'job_dollars'
include JobDollars
```

To use it in an object-oriented system, just require the gem during the boot process and include the `JobDollars` module where you plan to do the job-dollar computations:

```
include JobDollars
```

### Adding data

The data format is a bit tricky because I have not automated the process yet. All of my data comes from [Indeed.com](www.indeed.com).

Here are the steps you need to follow if you want to compute job-dollars for a technology not already in the [job_dollars.yml](https://github.com/tb0yd/job_dollars/blob/master/lib/job_dollars.yml) file:

1. Create a new section for your technology in job_dollars.yml.
2. Do the job search and resume search for your technology on [Indeed.com](www.indeed.com).
3. In the job results, open the refinements "Entry-level", "Mid-level", and "Senior-level" in new tabs.
4. Copy and paste the salary refinements on the left sidebar for each category into a key-value pair, either `entry`, `mid`, or `senior`, under `salaries` in your new section in job_dollars.yml.
5. Grab the total number of jobs for each category and put it under the `jobs` subsection, also labeled by category.
6. Grab the total number of resumes for your technology and paste it in `resumes` in your section.
7. Make sure the structure of the YAML you created matches the existing sections exactly.
