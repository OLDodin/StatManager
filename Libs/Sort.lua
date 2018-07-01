local max_chunk_size = 12 
local function insertion_sort( array, first, last, goes_before ) 
  for i = first + 1, last do 
    local k = first 
    local v = array[i] 
    for j = i, first + 1, -1 do 
      if goes_before( v, array[j-1] ) then 
        array[j] = array[j-1] 
      else 
        k = j 
        break 
      end 
    end 
    array[k] = v 
  end 
end 
local function merge( array, workspace, low, middle, high, goes_before ) 
  local i, j, k 
  i = 1 
  -- Copy first half of array to auxiliary array 
  for j = low, middle do 
    workspace[ i ] = array[ j ] 
    i = i + 1 
  end 
  i = 1 
  j = middle + 1 
  k = low 
  while true do 
    if (k >= j) or (j > high) then 
      break 
    end 
    if goes_before( array[ j ], workspace[ i ] )  then 
      array[ k ] = array[ j ] 
      j = j + 1 
    else 
      array[ k ] = workspace[ i ] 
      i = i + 1 
    end 
    k = k + 1 
  end 
  -- Copy back any remaining elements of first half 
  for k = k, j-1 do 
    array[ k ] = workspace[ i ] 
    i = i + 1 
  end 
end 
local function merge_sort( array, workspace, low, high, goes_before ) 
  if high - low < max_chunk_size then 
    insertion_sort( array, low, high, goes_before ) 
  else 
    local middle = math.floor((low + high)/2) 
    merge_sort( array, workspace, low, middle, goes_before ) 
    merge_sort( array, workspace, middle + 1, high, goes_before ) 
    merge( array, workspace, low, middle, high, goes_before ) 
  end 
end 

function stable_sort( array, goes_before ) 
--[[ ���������
	-- array = ���������� ���������� � 1...n
	-- goes_before - �������������� ��������
]]
 
  local n = table.getn(array)
  --
  if n < 2 then  return array  end 
  goes_before = goes_before or 
  function (a, b)
    PrintTable(b)
    return a < b
  end 
 
  local workspace = {} 
  --  Allocate some room. 
  workspace[ math.floor( (n+1)/2 ) ] = array[1] 
  merge_sort( array, workspace, 1, n, goes_before ) 
  return array 
end 


--[[ ���������
1	������������
17	�����������
3	���������-�������
10	����������
13	������� �����
15	����������,����������-�������
12	��������
18	��������
16	����������
8	�������-�����
7	��������
14	������
4	���������
9	��������� ����,��������
6	������� �����
5	�����������
2	Ҹ���-�������,���������
19	Ҹ���-�������,���������,���������
0	����
20	����,������������
11	����������
]]
--[[ �������� ������� � ���
function getStr()
	local Str = {}
	Str[1]="����"
	Str[2]="������������"
	Str[3]="Ҹ���-�������,���������"
	Str[4]="���������-�������"
	Str[5]="���������"
	Str[6]="�����������"
	Str[7]="������� �����"
	Str[8]="��������"
	Str[9]="�������-�����"
	Str[10]="��������� ����,��������"
	Str[11]="����������"
	Str[12]="����������"
	Str[13]="��������"
	Str[14]="������� �����"
	Str[15]="������"
	Str[16]="����������,����������-�������"
	Str[17]="����������"
	Str[18]="�����������"
	Str[19]="��������"
	Str[20]="Ҹ���-�������,���������,���������"
	Str[21]="����,������������"

	return Str
end
local Str = getStr()

--local StrResult = stable_sort(Str)
print("----------------")

local sort = function (a, b)  return a < b  end
table.sort(Str,sort)


for i = 1, #Str, 1 do
	--local a = StrResult[i-1]
	--local b = StrResult[i]
	--print(i,"=",a,"<",b,sort(a,b))
	
	print(i,"=",Str[i])
	
end
]]
--[[ �������� ������ � ������� (���������� �� ���� �����)


function getStrT()
  local Str = {}
Str[1]={["id"]=19,["name"]="����",["count"]=1}
Str[2]={["id"]=1,["name"]="������������",["count"]=1}
Str[3]={["id"]=17,["name"]="Ҹ���-�������,���������",["count"]=1}
Str[4]={["id"]=3,["name"]="���������-�������",["count"]=1}
Str[5]={["id"]=13,["name"]="���������",["count"]=1}
Str[6]={["id"]=16,["name"]="�����������",["count"]=1}
Str[7]={["id"]=15,["name"]="������� �����",["count"]=1}
Str[8]={["id"]=11,["name"]="��������",["count"]=2}
Str[9]={["id"]=10,["name"]="�������-�����",["count"]=2}
Str[10]={["id"]=14,["name"]="��������� ����,��������",["count"]=2}
Str[11]={["id"]=4,["name"]="����������",["count"]=2}
Str[12]={["id"]=21,["name"]="����������",["count"]=2}
Str[13]={["id"]=7,["name"]="��������",["count"]=2}
Str[14]={["id"]=5,["name"]="������� �����",["count"]=2}
Str[15]={["id"]=12,["name"]="������",["count"]=5}
Str[16]={["id"]=6,["name"]="����������,����������-�������",["count"]=5}
Str[17]={["id"]=9,["name"]="����������",["count"]=5}
Str[18]={["id"]=2,["name"]="�����������",["count"]=5}
Str[19]={["id"]=8,["name"]="��������",["count"]=5}
Str[20]={["id"]=18,["name"]="Ҹ���-�������,���������,���������",["count"]=5}
Str[21]={["id"]=20,["name"]="����,������������",["count"]=5}




	return Str
end
local Str1 = getStrT()
print("-------�������� ������ � ������� (���������� �� ���� �����)---------")
local sort = function (a, b) return (a.count <= b.count) and (a.name < b.name) end
Str = stable_sort(Str1,sort)
--table.sort(Str,sort)
for i = 1, #Str, 1 do
	print(i,"=",Str[i].name , " id = ", Str[i].id, "count" , Str[i].count)
end


]]



