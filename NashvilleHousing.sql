select * from PortfolioProject.dbo.NashvilleHousing

--Cleaning data using SQL queries

--Standardize Date Format
select saledate,convert(date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing add ConvertedSaleDate Date

update PortfolioProject.dbo.NashvilleHousing set ConvertedSaleDate = convert(date,SaleDate)

--Populate Property Address
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a join
PortfolioProject.dbo.NashvilleHousing b on a.ParcelID=b.ParcelID
and a.[UniqueID] <> b.[UniqueID] where a.PropertyAddress is null

update a 
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a join
PortfolioProject.dbo.NashvilleHousing b on a.ParcelID=b.ParcelID
and a.[UniqueID] <> b.[UniqueID] where a.PropertyAddress is null

--Breaking address into individual columns
select substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing add PropertyAddressSplit nvarchar(255)

update PortfolioProject.dbo.NashvilleHousing set PropertyAddressSplit=substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table PortfolioProject.dbo.NashvilleHousing add PropertyCity nvarchar(255)
update PortfolioProject.dbo.NashvilleHousing set PropertyCity=substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

--owner address
select parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing


alter table PortfolioProject.dbo.NashvilleHousing add OwnerAddressSplit nvarchar(255)
update PortfolioProject.dbo.NashvilleHousing set OwnerAddressSplit=parsename(replace(OwnerAddress,',','.'),3)


alter table PortfolioProject.dbo.NashvilleHousing add OwnerCity nvarchar(255)
update PortfolioProject.dbo.NashvilleHousing set OwnerCity=parsename(replace(OwnerAddress,',','.'),2)

alter table PortfolioProject.dbo.NashvilleHousing add OwnerState nvarchar(255)
update PortfolioProject.dbo.NashvilleHousing set OwnerState=parsename(replace(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in SoldAsVacant
select SoldAsVacant, 
case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant end from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing set SoldAsVacant = case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
else SoldAsVacant end

select SoldAsVacant,count(SoldAsVacant) from PortfolioProject.dbo.NashvilleHousing group by SoldAsVacant;

--Remove Duplicates

WITH RowNumCTE AS
(
select *,
ROW_NUMBER() over (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID)
			 row_num
from PortfolioProject.dbo.NashvilleHousing
)
Delete from RowNumCTE
where row_num>1


--Delete unused columns
alter table PortfolioProject.dbo.NashvilleHousing 
drop column OwnerAddress,PropertyAddress,SaleDate,TaxDistrict