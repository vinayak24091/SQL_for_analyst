------------------------------------------------------------------------------------------------------------------------------------
--CLEANING DATA IN SQL QUERIES
SELECT *
FROM NASH

-- STANDARDIZE DATE FORMAT
SELECT SaleDate, convert(date,SaleDate)
from nash

update nash
set SaleDate = convert(date,SaleDate)

alter table nash
add SaleDateConverted date;

update nash
set SaleDateConverted= CONVERT(date,SaleDate)

SELECT SaleDateConverted
from nash

-------------------------------------------------------------------------------------------------------------------------------------
--POPULATE PROPERTY ADDRESS DATA

select *
from nash
order by [UniqueID ],ParcelID

select a.PropertyAddress,a.ParcelID,b.PropertyAddress,b.ParcelID
from nash a
join nash b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

select a.PropertyAddress,a.ParcelID,b.PropertyAddress,b.ParcelID,isnull(a.PropertyAddress,b.PropertyAddress)
from nash a
join nash b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from nash a
join nash b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMN

SELECT PropertyAddress
from nash

select
PARSENAME(replace(PropertyAddress, ',', '.'), 1)
,PARSENAME(replace(PropertyAddress, ',', '.'), 2)
from nash



select OwnerAddress
from NASHVILLE..nash

select
PARSENAME(replace(OwnerAddress, ',', '.'),3)
,PARSENAME(replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from NASHVILLE..nash

alter table NASHVILLE..nash
add OwnerSplitAddress Nvarchar(255);

update NASHVILLE..nash
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'),3)

alter table NASHVILLE..nash
add OwnerSplitCity nvarchar(255);


update NASHVILLE..nash
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'),2)

alter table NASHVILLE..nash
add OwnerSplitState nvarchar(255);

update NASHVILLE..nash
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'),1)

------------------------------------------------------------------------------------------------------------------------------------------------


--look at the last 3 columns of the table
select *
from NASHVILLE..nash

---------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldasVacant)
from NASHVILLE..nash
group by SoldAsVacant
order by 2

select SoldasVacant
, CASE when SoldasVacant = 'Y' then 'Yes'
	   when SoldasVacant = 'N' then 'No'
       	else SoldAsVacant
		END
from NASHVILLE..nash


update NASHVILLE..nash
set SoldAsVacant = CASE when SoldasVacant = 'Y' then 'Yes'
					    when SoldasVacant = 'N' then 'No'
                    	else SoldAsVacant
		                END
---------------------------------------------------------------------------------------------------------------------

--REMOVE DUPLICATES
select *,
	ROW_NUMBER() over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num 
					from NASHVILLE..nash



--------------------------------------------------------------------------------------------------------------------------------

-- REMOVING UNUSED COLUMNS
select *
from NASHVILLE..nash


alter table NASHVILLE..nash
DROP column OwnerName,OwnerAddress,TaxDistrict

alter table NASHVILLE..nash
Drop column SaleDate