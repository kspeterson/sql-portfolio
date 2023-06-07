SELECT * FROM DataCleaning..NashvilleHousing

-- Standardize date format
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM DataCleaning..NashvilleHousing

ALTER TABLE DataCleaning..NashvilleHousing
ADD SaleDateConverted Date;

UPDATE DataCleaning..NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted 
FROM DataCleaning..NashvilleHousing

--Populate property address data
SELECT * FROM DataCleaning..NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning..NashvilleHousing a
JOIN DataCleaning..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning..NashvilleHousing a
JOIN DataCleaning..NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]

-- Separate address by street, city, and state into individual columns
SELECT PropertyAddress FROM DataCleaning..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City

FROM DataCleaning..NashvilleHousing

ALTER TABLE DataCleaning..NashvilleHousing
ADD PropertyStreet nvarchar(255);

UPDATE DataCleaning..NashvilleHousing
SET PropertyStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE DataCleaning..NashvilleHousing
ADD PropertyCity nvarchar(255);

UPDATE DataCleaning..NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DataCleaning..NashvilleHousing

ALTER TABLE DataCleaning..NashvilleHousing
ADD OwnerStreet nvarchar(255);

UPDATE DataCleaning..NashvilleHousing
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE DataCleaning..NashvilleHousing
ADD OwnerCity nvarchar(255);

UPDATE DataCleaning..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE DataCleaning..NashvilleHousing
ADD OwnerState nvarchar(255);

UPDATE DataCleaning..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Changing the Y and N in SoldAsVacant column
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM DataCleaning..NashvilleHousing
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM DataCleaning..NashvilleHousing

UPDATE DataCleaning..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
FROM DataCleaning..NashvilleHousing
	)

SELECT * FROM RowNumCTE
WHERE row_num > 1

--Delete Unused Columns
ALTER TABLE DataCleaning..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate