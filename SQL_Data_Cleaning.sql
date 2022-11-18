--Looking at all the data

SELECT *
FROM PortfolioProject2..NashvilleHousingData
ORDER BY 1

-----------------------------------------------------

--Converting SaleDate column to suitable format

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM PortfolioProject2..NashvilleHousingData

ALTER table NashvilleHousingData
    ALTER COLUMN SaleDate DATE

-----------------------------------------------------

--Handling NULL values in PropertyAddress column

SELECT UniqueID, PropertyAddress
FROM PortfolioProject2..NashvilleHousingData
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousingData a
JOIN PortfolioProject2..NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress IS NULL

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousingData a
JOIN PortfolioProject2..NashvilleHousingData b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-----------------------------------------------------

--Extracting information from PropertyAddress column (street and city)

SELECT *
FROM PortfolioProject2..NashvilleHousingData
ORDER BY 1

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS PropertyStreetAdress, 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS PropertyCity
FROM PortfolioProject2..NashvilleHousingData

ALTER TABLE PortfolioProject2..NashvilleHousingData
ADD PropertyStreetAddress Nvarchar(255);

UPDATE PortfolioProject2..NashvilleHousingData
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE PortfolioProject2..NashvilleHousingData
ADD PropertyCity Nvarchar(255);

UPDATE PortfolioProject2..NashvilleHousingData
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-----------------------------------------------------

--Extracting information from OwnerAddress column (owner's street, city and state)

SELECT *
FROM PortfolioProject2..NashvilleHousingData
ORDER BY 1

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerStreetAddress,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM PortfolioProject2..NashvilleHousingData;

ALTER TABLE PortfolioProject2..NashvilleHousingData
ADD OwnerStreetAddress NVARCHAR(255);

UPDATE PortfolioProject2..NashvilleHousingData
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE PortfolioProject2..NashvilleHousingData
ADD OwnerCity NVARCHAR(255);

UPDATE PortfolioProject2..NashvilleHousingData
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE PortfolioProject2..NashvilleHousingData
ADD OwnerState NVARCHAR(255);

UPDATE PortfolioProject2..NashvilleHousingData
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

-----------------------------------------------------

--Removing redundant data (entries that containg no new relevant information)

WITH SubQuery AS (
SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID, LegalReference, PropertyStreetAddress
	ORDER BY UniqueID) AS DuplicateCount
FROM PortfolioProject2..NashvilleHousingData
)
DELETE FROM SubQuery
WHERE DuplicateCount > 1;


WITH SubQuery AS (
SELECT *, ROW_NUMBER() OVER (
	PARTITION BY ParcelID, LegalReference, PropertyStreetAddress
	ORDER BY UniqueID) AS DuplicateCount
FROM PortfolioProject2..NashvilleHousingData
)
SELECT *
FROM SubQuery
WHERE DuplicateCount > 1;

-----------------------------------------------------

--Removing redundant data (columns that containg no new relevant information)

ALTER TABLE PortfolioProject2..NashvilleHousingData
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, OwnerName;

SELECT *
FROM PortfolioProject2..NashvilleHousingData
ORDER BY 1