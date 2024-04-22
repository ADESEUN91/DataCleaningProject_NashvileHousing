
--Cleaning data in SQL queries

select *
From portfolioproject.dbo.NashvileHousing


--standadize date format

select saledate, CONVERT(Date,saledate) as DateofSale
From portfolioproject.dbo.NashvileHousing

-- Method 1
Update NashvileHousing
set saledate = CONVERT(Date,saledate)

--Method 2
ALTER TABLE NashvileHousing
Add saledateconverted Date;

Update NashvileHousing
set saledateconverted = CONVERT(Date,saledate)


-- populate property address data

select *
From portfolioproject.dbo.NashvileHousing
where PropertyAddress is null
Order by ParcelID


select a.parcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolioproject.dbo.NashvileHousing a
Join portfolioproject.dbo.NashvileHousing b
on a.parcelID = b.parcelID
AND a.[UniqueID] <> b.[UniqueID]
where PropertyAddress is null
Order by ParcelID

update a
SET PropertyAddress = ISNULL(a.propertyAddress, b.propertyAddress)
From portfolioproject.dbo.NashvileHousing a
Join portfolioproject.dbo.NashvileHousing b
on a.parcelID = b.parcelID
AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

--correction 

SELECT
    a.parcelID,
    a.PropertyAddress AS PropertyAddress_a,
    b.ParcelID,
    b.PropertyAddress AS PropertyAddress_b,
    COALESCE(a.PropertyAddress, b.PropertyAddress) AS Merged_PropertyAddress
FROM
    portfolioproject.dbo.NashvileHousing a
JOIN
    portfolioproject.dbo.NashvileHousing b
ON
    a.parcelID = b.parcelID
    AND a.[UniqueID] <> b.[UniqueID]
--WHERE
  --  COALESCE(a.PropertyAddress, b.PropertyAddress) IS NULL
ORDER BY
    a.ParcelID;






	-- Breaking out address into individual columns (Address, city, state)

SELECT *
FROM portfolioproject.dbo.NashvileHousing
-- WHERE PropertyAddress is null
-- ORDER BY ParcelID

SELECT  
-- CHARINDEX Means Character Index
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

FROM portfolioproject.dbo.NashvileHousing

-- Update new address and city in Table

ALTER TABLE NashvileHousing
Add PropertySplitAddress NVARCHAR(255);



UPDATE portfolioproject.dbo.NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);


ALTER TABLE NashvileHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE  portfolioproject.dbo.NashvileHousing
SET PropertySplitcITY = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT *
FROM portfolioproject.dbo.NashvileHousing


-- Using PARSENAME on the owner Address
SELECT *
FROM portfolioproject.dbo.NashvileHousing

-- parsename only recognise full stop as against commas in the address so commas in the statement
--needs to be replaced wth full stops.
--Also parsename split in the opposite direction so you might have to reorder the plit in 3,2,1 as against 1,2,3.

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) 
FROM portfolioproject.dbo.NashvileHousing


-- To Update Table

ALTER TABLE NashvileHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE  portfolioproject.dbo.NashvileHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) ;

ALTER TABLE NashvileHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE  portfolioproject.dbo.NashvileHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) ;



ALTER TABLE NashvileHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE  portfolioproject.dbo.NashvileHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM portfolioproject.dbo.NashvileHousing



-- To Change Y and N to Yes and No in Sold as Vacant Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolioproject.dbo.NashvileHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Replace y and N with Yes and No
SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM portfolioproject.dbo.NashvileHousing


-- update the table

UPDATE  portfolioproject.dbo.NashvileHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END

--Observe Output Change
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolioproject.dbo.NashvileHousing
GROUP BY SoldAsVacant
ORDER BY 2



--- To Remove Duplicates


--To Delete

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
ORDER BY 
UniqueID
)Row_num

FROM portfolioproject.dbo.NashvileHousing
--Order By ParcelID
)

DELETE
FROM RowNumCTE
Where row_num > 1
--ORDER BY PropertyAddress


-- to Check
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
ORDER BY 
UniqueID
)Row_num

FROM portfolioproject.dbo.NashvileHousing
--Order By ParcelID
)

Select *
FROM RowNumCTE
Where row_num > 1
ORDER BY PropertyAddress



-- To Delete Unused Coloumn

SELECT *
FROM portfolioproject.dbo.NashvileHousing

ALTER TABLE portfolioproject.dbo.NashvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE portfolioproject.dbo.NashvileHousing
DROP COLUMN SaleDate