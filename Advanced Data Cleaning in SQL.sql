/*

Cleaning Data in SQL Queries

*/


SELECT *
FROM [Portfolio Project].[dbo].[NashvilleHousing]


-----------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate
	  ,CONVERT(Date, SaleDate)
FROM [Portfolio Project].[dbo].[NashvilleHousing]



ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;


UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)



SELECT SaleDateConverted
	  ,CONVERT(Date, SaleDate)
FROM [Portfolio Project].[dbo].[NashvilleHousing]



----------------------------------------------------------------------------------------

--Populate Property Address data

SELECT *
FROM [Portfolio Project].[dbo].[NashvilleHousing]
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID



SELECT a.ParcelID
	  ,a.PropertyAddress
	  ,b.ParcelID
	  ,b.PropertyAddress
	  ,ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].[dbo].[NashvilleHousing] a
JOIN [Portfolio Project].[dbo].[NashvilleHousing] B
	 ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Portfolio Project].[dbo].[NashvilleHousing] a
JOIN [Portfolio Project].[dbo].[NashvilleHousing] B
	 ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


---------------------------------------------------------------------------------------

--Breaking out Property Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM [Portfolio Project].[dbo].[NashvilleHousing]


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
	  ,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM [Portfolio Project].[dbo].[NashvilleHousing]



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM [Portfolio Project].[dbo].[NashvilleHousing]

---------------------------------------------------------------------------------------

--Breaking out Owner Address into Individual Columns (Address, City, State)

SELECT OwnerAddress
FROM [Portfolio Project].[dbo].[NashvilleHousing]



SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
	  ,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
	  ,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM [Portfolio Project].[dbo].[NashvilleHousing]



ALTER TABLE NashvilleHousing
ADD	OwnerSplitAddress nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)



ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)




ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


SELECT *
FROM [Portfolio Project].[dbo].[NashvilleHousing]


---------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold  as Vacant" field


SELECT DISTINCT(SoldAsVacant)
	  ,COUNT(SoldAsVacant)
FROM [Portfolio Project].[dbo].[NashvilleHousing]
GROUP BY SoldAsVacant
ORDER BY 2

--So, we only want to keep YES and NO

SELECT SoldAsVacant
	  ,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		    WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END
FROM [Portfolio Project].[dbo].[NashvilleHousing]



UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
						 END

---------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *
	  ,ROW_NUMBER() OVER (PARTITION BY ParcelID
									  ,PropertyAddress
									  ,SalePrice
									  ,SaleDate
									  ,LegalReference ORDER BY UniqueID) AS row_num
FROM [Portfolio Project].[dbo].[NashvilleHousing])

--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress

DELETE 
FROM RowNumCTE
WHERE row_num > 1



SELECT *
FROM [Portfolio Project].[dbo].[NashvilleHousing]



---------------------------------------------------------------------------------------

--DELETE unused Columns

ALTER TABLE [Portfolio Project].[dbo].[NashvilleHousing]
DROP COLUMN OwnerAddress
           ,TaxDistrict
		   ,PropertyAddress
		   ,SaleDate



SELECT *
FROM [Portfolio Project].[dbo].[NashvilleHousing]