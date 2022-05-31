Select * FROM nashvillehousing

-- Shorten date of SaleDate column

UPDATE nashvillehousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER table nashvillehousing
ADD sale_date date;

UPDATE nashvillehousing
SET sale_date = CONVERT(Date,SaleDate)



--Replace Null with Property Address

Select *
FROm nashvillehousing
Where PropertyAddress IS NULL

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashvillehousing a
Join nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashvillehousing a
Join nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Seperate Propertyaddress column into seperate adress and city columns

Select PropertyAddress
FROm nashvillehousing

SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as address

FROm nashvillehousing

ALTER table nashvillehousing
ADD Property_address Nvarchar(255);

UPDATE nashvillehousing
SET Property_address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER table nashvillehousing
ADD Property_city nvarchar(255);

UPDATE nashvillehousing
SET Property_city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * FROM nashvillehousing


-- Seperateing OwnerAddress in adress, city and state columns

SELECT OwnerAddress FROM nashvillehousing

SELECT 
PARSENAME(REPLACE(Owneraddress,',','.'),3),
PARSENAME(REPLACE(Owneraddress,',','.'),2),
PARSENAME(REPLACE(Owneraddress,',','.'),1)
FROM nashvillehousing

ALTER table nashvillehousing
ADD owner_address Nvarchar(255);

UPDATE nashvillehousing
SET owner_address = PARSENAME(REPLACE(Owneraddress,',','.'),3)

ALTER table nashvillehousing
ADD owner_city Nvarchar(255);

UPDATE nashvillehousing
SET owner_city = PARSENAME(REPLACE(Owneraddress,',','.'),2)

ALTER table nashvillehousing
ADD owner_state Nvarchar(255);

UPDATE nashvillehousing
SET owner_state = PARSENAME(REPLACE(Owneraddress,',','.'),1)

-- Convert 'N' and 'Y' to 'Yes' and 'No' in SoldVacant Column

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant ='Y' THEN 'YES'
	 WHEN SoldAsVacant ='N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM nashvillehousing

update nashvillehousing
set SoldAsVacant=CASE WHEN SoldAsVacant ='Y' THEN 'YES'
	 WHEN SoldAsVacant ='N' THEN 'NO'
	 ELSE SoldAsVacant
	 END

-- REMOVE DUPLICATES

WITH rownumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
Partition BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID
			 ) row_num
FROM nashvillehousing
)

SELECT *
FROM rownumCTE
Where row_num > 1


--DELETE UNUSED COLUMNS

SELECT * FROM nashvillehousing

ALTER TABLE nashvillehousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict
