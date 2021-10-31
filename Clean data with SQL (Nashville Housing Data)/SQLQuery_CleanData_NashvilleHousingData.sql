 
 use PortfolioProject

 Select SaleDate from NashvilleHousing

-- Standardize Data Format

-- Sale date -> No One has Time so convert to just date

Select SaleDate,CONVERT(date,SaleDate)  from NashvilleHousing

--We should change data type (for real project its better to Create New Column)
Alter Table NashvilleHousing 
	ALTER  column saledate date;

update NashvilleHousing set SaleDate = CONVERT(date,SaleDate)

-------------------------------------------------------------------------------------------------------------------------

-- Populate Property Adress data

-- we have some Adress that is null 
-- when we explore data we can find out that we can find this data by other same parcelID

select top 5 a.PropertyAddress,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress) from
	NashvilleHousing as a join
	NashvilleHousing as b
		on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
			where a.PropertyAddress is null


update a set PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress) from
	NashvilleHousing as a join
	NashvilleHousing as b
		on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
			where a.PropertyAddress is null


-------------------------------------------------------------------------------------------------------------------------

-- Split address into individual column (Adress, City, State)

-- if COMPATIBILITY_LEVEL > 12, we can use STRING_SPLIT but its harder for this

Select top 5 
	SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) ,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))
	from NashvilleHousing

Alter Table NashvilleHousing
	Add [Address] Nvarchar(255);-- in this project we dont tuning type 

Update NashvilleHousing
	Set [address] = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
	Add  city Nvarchar(255);

Update NashvilleHousing
	Set city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

-- PARSENAME is better idea (we use this for ownAddress)

Alter Table NashvilleHousing
	Add  OwnerAdress Nvarchar(255);


Alter Table NashvilleHousing
	Add  OwnerCity Nvarchar(255);

Alter Table NashvilleHousing
	Add  OwnerState Nvarchar(255);

Update NashvilleHousing
	Set OwnerAdress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
		OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
		OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


-------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in Sold as Vacant 

Select distinct(SoldAsVacant), Count(SoldAsVacant)
	from NashvilleHousing
	group by SoldAsVacant
	order by 2

-- it seems that Y and N is not correct

Select 
	case
		 when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
	 end
	from NashvilleHousing


update NashvilleHousing 
	set SoldAsVacant= 
		case
			 when SoldAsVacant = 'Y' then 'Yes'
			 when SoldAsVacant = 'N' then 'No'
			 else SoldAsVacant
		 end
	 

-------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates in (real project we dont remove actully)

--diffrenet options rowranks,rownumber

-- note: we should partion by some thing is important for us unique

With CTE as (
	Select *,
			Row_Number() over(partition by 
			ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference order by UniqueID) row_num
		from NashvilleHousing
		
)
delete from CTE where row_num >1
--Select * from CTE where row_num >1



-------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

	-- First Talk to supervisor 

Alter Table NashvilleHousing
Drop Column OwnerAddress,TaxDistrict,PropertyAddress
 