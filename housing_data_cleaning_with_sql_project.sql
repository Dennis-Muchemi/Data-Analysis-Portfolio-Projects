/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM Portfolio_project..NashvilleHousing


--Standardize Date Formart

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Portfolio_project..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD sale_date_converted DATE;

UPDATE NashvilleHousing
SET sale_date_converted = CONVERT(Date, SaleDate)

SELECT Sale_date_converted
FROM Portfolio_project..NashvilleHousing



--Populate Property Address Data Where property address is null
SELECT *
FROM Portfolio_project.dbo.NashvilleHousing
WHERE PropertyAddress = Null

SELECT a.ParcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_project..NashvilleHousing a
JOIN Portfolio_project..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_project..NashvilleHousing a
JOIN Portfolio_project..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



-- Breaking out Address into Individual Columns, Population address and Owner Address, (Address, City, State)

--splitting Property Address Column

SELECT PropertyAddress
fROM Portfolio_project..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM Portfolio_project..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD property_split_address NVARCHAR(255);

UPDATE NashvilleHousing
SET property_split_address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD property_split_city NVARCHAR(255);

UPDATE NashvilleHousing
SET property_split_city = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
fROM Portfolio_project..NashvilleHousing



--splitting OwnerAddress

SELECT OwnerAddress
FROM Portfolio_project..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Portfolio_project..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD owner_split_address NVARCHAR(255);

UPDATE NashvilleHousing
SET owner_split_address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD owner_split_city NVARCHAR(255);

UPDATE NashvilleHousing
SET owner_split_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD owner_split_state NVARCHAR(255);

UPDATE NashvilleHousing
SET owner_split_state = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM Portfolio_project..NashvilleHousing




--Change Y and N into Yes and No in "Sold as vacant" fields

SELECT DISTINCT(SoldAsVacant)
FROM Portfolio_project..NashvilleHousing

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM Portfolio_project..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_project..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2




--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM Portfolio_project..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM Portfolio_project..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1








--Delete Unused Columns

ALTER TABLE Portfolio_project..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

SELECT *
FROM Portfolio_project..NashvilleHousing