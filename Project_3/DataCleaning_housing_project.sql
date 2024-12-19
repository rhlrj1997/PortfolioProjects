select *
from Portfolio_project..NashvilleHousing


--standardise date format

select saledate, SaleDateConverted
from NashvilleHousing;

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

--Populate Property Address data

select *
from nashvillehousing 
where propertyaddress is null

select *
from nashvillehousing
order by parcelid

select a.uniqueid, a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress 
from Portfolio_project..nashvillehousing a
join portfolio_project..nashvillehousing b
	on a.parcelid = b.parcelid
	and a.uniqueid = b.uniqueid
where a.propertyaddress is null;


select a.uniqueid, a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress
,isnull(a.propertyaddress,b.propertyaddress)
from Portfolio_project..nashvillehousing a
join portfolio_project..nashvillehousing b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null 

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from Portfolio_project..nashvillehousing a
join portfolio_project..nashvillehousing b
	on a.parcelid = b.parcelid
	and a.uniqueid <> b.uniqueid
where a.propertyaddress is null  


-- breaking out address into individual columns( address, city, state)

select *
from nashvillehousing;


select
SUBSTRING(propertyaddress,1, charindex(',',propertyaddress)-1) as address,
substring(propertyaddress,charindex(',',propertyaddress)+1, len(propertyaddress)) as town
from nashvillehousing

alter table nashvillehousing
add PropertySplitAddress nvarchar(255);

update nashvillehousing
set PropertySplitAddress = SUBSTRING(propertyaddress,1, charindex(',',propertyaddress)-1);

alter table nashvillehousing
add PropertySplitCity nvarchar(255);

update nashvillehousing
set PropertySplitCity = substring(propertyaddress,charindex(',',propertyaddress)+1, len(propertyaddress)); 

--using parsename for splitting substring

select *
from nashvillehousing

select
parsename(replace(owneraddress, ',', '.'), 1)
,parsename(replace(owneraddress, ',', '.'), 2)
,parsename(replace(owneraddress, ',', '.'), 3)
from nashvillehousing

alter table nashvillehousing
add OwnerSplitAddress nvarchar(255);

update nashvillehousing
set OwnerSplitAddress = parsename(replace(owneraddress, ',', '.'), 3)

alter table nashvillehousing
add OwnerSplitCity nvarchar(255);

update nashvillehousing
set  OwnerSplitCity = parsename(replace(owneraddress, ',', '.'), 2)

alter table nashvillehousing
add OwnerSplitState nvarchar(255);

update nashvillehousing
set OwnerSplitState = parsename(replace(owneraddress, ',', '.'), 1)


--change Y and N to Yes and No in 'Sold as Vacant' field

select distinct(soldasvacant), count(soldasvacant)
from nashvillehousing
group by soldasvacant
order by 2


select soldasvacant
,case when soldasvacant = 'Y' then 'Yes'
      when soldasvacant = 'N' then 'No'
	  else soldasvacant
	  end
from nashvillehousing


update nashvillehousing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
      when soldasvacant = 'N' then 'No'
	  else soldasvacant
	  end 


--remove duplicates


select *,
	Row_number() Over (
	partition by parcelid,
	             Propertyaddress,
				 Saleprice,
				 Legalreference
				 Order by
					Uniqueid
					) row_num
from NashvilleHousing;

with RowNumCTE AS (
select *,
	Row_number() Over (
	partition by parcelid,
	             Propertyaddress,
				 Saleprice,
				 Legalreference
				 Order by
					Uniqueid
					) row_num
from NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
order by propertyaddress

--deleting the duplicates using cte
with RowNumCTE AS (
select *,
	Row_number() Over (
	partition by parcelid,
	             Propertyaddress,
				 Saleprice,
				 Legalreference
				 Order by
					Uniqueid
					) row_num
from NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1								
--order by propertyaddress		


--deleting unused columns

select *
from Portfolio_project..NashvilleHousing;


alter table Portfolio_project..NashvilleHousing
drop column OwnerAddress, PropertyAddress, TaxDistrict;


alter table Portfolio_project..NashvilleHousing
drop column Saledate;