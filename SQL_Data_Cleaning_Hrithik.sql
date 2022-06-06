/* 
Cleaning data with SQL Queries
*/ 

select top 100 * from dbo.housing

/* 
1.Column names
*/ 
select TOP 0 * FROM dbo.housing


/* 
2.Standardize date format: Removing time part data as it is 0
*/ 

Select Saledate, CAST(Saledate as Date) as sale_date_new FROM housing

ALTER TABLE housing
ADD Salesdate_new date;

UPDATE housing
SET Salesdate_new=CAST(Saledate as Date)

Select TOP 100 Salesdate_new FROM housing

--3.Populating Null Propert Address

Select *  from housing
WHERE propertyaddress IS NULL;

--I noticed that for same parcelID property address is present in one row and absent in the second , we can populate using Parcel id through self join

SELECT a.ParcelID,a.propertyaddress,b.ParcelID,b.propertyaddress
FROM housing a 
JOIN housing b
on a.ParcelID= b.ParcelID
and a.uniqueID <> b.UniqueID
where a.propertyaddress is null


UPDATE a
SET propertyaddress=ISNULL(a.propertyaddress,b.propertyaddress)
FROM housing a 
JOIN housing b
on a.ParcelID= b.ParcelID
and a.uniqueID <> b.UniqueID
where a.propertyaddress is null


-- Null values are removed


--4.Breaking out Address into Individual Columns (Address, City, State)
--Splitting propertyaddress

Select propertyaddress FROM housing

ALTER TABLE housing
ADD PA_Splitaddress nvarchar(250);


ALTER TABLE housing
ADD PA_Splitcity nvarchar(250);

UPDATE Housing 
SET PA_Splitaddress=SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)

UPDATE Housing 
SET PA_Splitcity=SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,LEN(propertyaddress))

Select propertyaddress,PA_Splitaddress,PA_Splitcity FROM housing

--Splitting owneraddress

Select OwnerAddress,SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1),
SUBSTRING(RIGHT(OwnerAddress,LEN(OwnerAddress)-CHARINDEX(',',OwnerAddress)),1,CHARINDEX(',',RIGHT(OwnerAddress,LEN(OwnerAddress)-CHARINDEX(',',OwnerAddress)))-1)

FROM housing

--Extracting substrings through charindex,substring,length can be confusing to understand sometimes so we use PARSENAME

Select OwnerAddress
From Housing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Housing



ALTER TABLE Housing
Add OwnerSplitAddress Nvarchar(255);

Update Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Housing
Add OwnerSplitCity Nvarchar(255);

Update Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE Housing
Add OwnerSplitState Nvarchar(255);

Update Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM Housing


--5.Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Housing
Group by SoldAsVacant
order by 2

--We see that there are 4 distinct values of Yes and No, since Yes and No are popular ones so we will change Y or N to YES/NO




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Housing


Update Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--6.Remove Duplicates

WITH RowNCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) AS row_num
From dbo.housing)

DELETE FROM RowNCTE
Where row_num > 1

--8.Delete Unused Columns



Select *
From Housing


ALTER TABLE Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
