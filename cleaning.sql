-- cleaning steps --
-- 1.remove duplicates
-- 2.standardize the data
-- 3.handling the no and null values
-- 4.remove unnecessary cols & rows

-- duplicates --

SELECT * 
FROM layoffs2.layoffs;

create table layoffs_stage
like layoffs2.layoffs;

select *
from layoffs_stage;

insert layoffs_stage
select *
from layoffs2.layoffs;

WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`
,stage,country,funds_raised_millions
) AS row_num
FROM layoffs_stage
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

CREATE TABLE `layoffs_stage2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_stage2;

insert into layoffs_stage2
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY company,location,industry,total_laid_off,percentage_laid_off,`date`
,stage,country,funds_raised_millions
) AS row_num
FROM layoffs_stage;

select *
from layoffs_stage2
where row_num>1;

 delete 
 from layoffs_stage2
 where row_num>1;

 -- standardizing --
 
 select company,TRIM(company) -- trim removes the white spaces before and after
 from layoffs_stage2;

 update layoffs_stage2
 set company=trim(company);

 select distinct industry -- we realize here that crypto = crypto currency!!
 from layoffs_stage2
 order by 1;
 
   select *
  from layoffs_stage2
  where industry like 'Crypto%';
  
  update layoffs_stage2
  set industry='Crypto'
  where industry = 'Crypto Currency';
  
 select distinct location
 from layoffs_stage2
 order by 1;
 
 select distinct country
 from layoffs_staging2
 order by 1;
 
 select `date`,
 str_to_date(`date`,'%m/%d/%Y')
 from layoffs_stage2;
 
  update layoffs_stage2
 set `date`=str_to_date(`date`,'%m/%d/%Y');
 
  select `date`
 from layoffs_stage2;
 
 alter table layoffs_stage2 -- change the datatype
 modify column `date` DATE;
 
  select *
 from layoffs_staging2
 where total_laid_off IS NULL or total_laid_off='';
 
  select distinct total_laid_off
 from layoffs_stage2;
 
  -- filling nulls --
  
 select t1.industry,t2.industry
 from layoffs_stage2 t1
 join layoffs_stage2 t2 -- self join
 on t1.company=t2.company
 and t1.location=t2.location
 where (t1.industry is null or t1.industry='')
 and t2.industry is not null;
 
 update layoffs_stage2
 set industry=null
 where industry ='';
 
 update layoffs_stage2 t1
 join  layoffs_stage2 t2
 on t1.company=t2.company
 set t1.industry = t2.industry 
 where t1.industry is null and t2.industry is not null ;
 
 select *
 from layoffs_stage2
 where (total_laid_off ='' or  total_laid_off is null)
 and (percentage_laid_off ='' or percentage_laid_off is null); -- means no layoffs
 
   delete 
 from layoffs_stage2
 where total_laid_off is null 
 and percentage_laid_off is null;
 
  alter table layoffs_stage2
 drop column row_num;
 
  select *
from layoffs_stage2;
