### Project Summary: Nashville Housing Data Cleaning and Transformation

#### Objective:
The objective of this project is to clean and standardize the Nashville housing dataset. This involves converting date formats, filling in missing property addresses, breaking out combined address fields into individual columns, transforming specific field values, and removing duplicate records. The goal is to prepare the data for accurate analysis and reporting.

#### Steps and Operations:

1. **Standardize Date Format:**
   - **Initial Query:**
     ```sql
     SELECT saledate, CONVERT(Date, saledate) AS DateofSale
     FROM portfolioproject.dbo.NashvileHousing;
     ```
   - **Update Date Format:**
     ```sql
     UPDATE portfolioproject.dbo.NashvileHousing
     SET saledate = CONVERT(Date, saledate);
     ```

2. **Populate Missing Property Addresses:**
   - **Identify Missing Addresses:**
     ```sql
     SELECT *
     FROM portfolioproject.dbo.NashvileHousing
     WHERE PropertyAddress IS NULL
     ORDER BY ParcelID;
     ```
   - **Fill Missing Addresses:**
     ```sql
     UPDATE a
     SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
     FROM portfolioproject.dbo.NashvileHousing a
     JOIN portfolioproject.dbo.NashvileHousing b
     ON a.parcelID = b.parcelID AND a.[UniqueID] <> b.[UniqueID]
     WHERE a.PropertyAddress IS NULL;
     ```

3. **Break Out Address into Individual Columns (Address, City):**
   - **Extract Address and City:**
     ```sql
     ALTER TABLE portfolioproject.dbo.NashvileHousing
     ADD PropertySplitAddress NVARCHAR(255),
         PropertySplitCity NVARCHAR(255);

     UPDATE portfolioproject.dbo.NashvileHousing
     SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
         PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));
     ```

4. **Split Owner Address into Individual Columns:**
   - **Using PARSENAME to Split Address:**
     ```sql
     ALTER TABLE portfolioproject.dbo.NashvileHousing
     ADD OwnerSplitAddress NVARCHAR(255),
         OwnerSplitCity NVARCHAR(255),
         OwnerSplitState NVARCHAR(255);

     UPDATE portfolioproject.dbo.NashvileHousing
     SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
         OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
         OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);
     ```

5. **Transform 'SoldAsVacant' Field Values:**
   - **Replace 'y' and 'N' with 'YES' and 'NO':**
     ```sql
     UPDATE portfolioproject.dbo.NashvileHousing
     SET SoldAsVacant = CASE
         WHEN SoldAsVacant = 'y' THEN 'YES'
         WHEN SoldAsVacant = 'N' THEN 'NO'
         ELSE SoldAsVacant
     END;
     ```

6. **Remove Duplicate Records:**
   - **Identify and Remove Duplicates:**
     ```sql
     WITH RowNumCTE AS (
         SELECT *,
             ROW_NUMBER() OVER (
                 PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                 ORDER BY UniqueID
             ) AS Row_num
         FROM portfolioproject.dbo.NashvileHousing
     )
     DELETE FROM RowNumCTE
     WHERE Row_num > 1;
     ```

7. **Delete Unused Columns:**
   - **Drop Unnecessary Columns:**
     ```sql
     ALTER TABLE portfolioproject.dbo.NashvileHousing
     DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
     ```

#### Conclusion:
This data cleaning and transformation project ensures that the Nashville housing dataset is standardized, complete, and ready for analysis. By converting date formats, filling in missing data, breaking out combined fields, transforming specific values, and removing duplicates, the dataset is now reliable for generating accurate insights and supporting decision-making processes.
