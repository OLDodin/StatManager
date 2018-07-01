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
--[[ Параметры
	-- array = индексация начинается с 1...n
	-- goes_before - необезательный параметр
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


--[[ результат
1	Баклажановый
17	Васильковый
3	Карминово-красный
10	Каштановый
13	Кобальт синий
15	Коралловый, кораллово-красный
12	Коричный
18	Кремовый
16	Кукурузный
8	Лазурно-синий
7	Лазурный
14	Медный
4	Морковный
9	Салатовый цвет, шартрез
6	Светлая вишня
5	Селадоновый
2	Тёмно-красный, кардинал
19	Тёмно-красный, кровавый,Малиновый
0	Хаки
20	Циан, васильковый
11	Шоколадный
]]
--[[ например ингдекс и имя
function getStr()
	local Str = {}
	Str[1]="Хаки"
	Str[2]="Баклажановый"
	Str[3]="Тёмно-красный, кардинал"
	Str[4]="Карминово-красный"
	Str[5]="Морковный"
	Str[6]="Селадоновый"
	Str[7]="Светлая вишня"
	Str[8]="Лазурный"
	Str[9]="Лазурно-синий"
	Str[10]="Салатовый цвет, шартрез"
	Str[11]="Каштановый"
	Str[12]="Шоколадный"
	Str[13]="Коричный"
	Str[14]="Кобальт синий"
	Str[15]="Медный"
	Str[16]="Коралловый, кораллово-красный"
	Str[17]="Кукурузный"
	Str[18]="Васильковый"
	Str[19]="Кремовый"
	Str[20]="Тёмно-красный, кровавый,Малиновый"
	Str[21]="Циан, васильковый"

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
--[[ например индекс и таблица (сортировка по двум полям)


function getStrT()
  local Str = {}
Str[1]={["id"]=19,["name"]="Хаки",["count"]=1}
Str[2]={["id"]=1,["name"]="Баклажановый",["count"]=1}
Str[3]={["id"]=17,["name"]="Тёмно-красный, кардинал",["count"]=1}
Str[4]={["id"]=3,["name"]="Карминово-красный",["count"]=1}
Str[5]={["id"]=13,["name"]="Морковный",["count"]=1}
Str[6]={["id"]=16,["name"]="Селадоновый",["count"]=1}
Str[7]={["id"]=15,["name"]="Светлая вишня",["count"]=1}
Str[8]={["id"]=11,["name"]="Лазурный",["count"]=2}
Str[9]={["id"]=10,["name"]="Лазурно-синий",["count"]=2}
Str[10]={["id"]=14,["name"]="Салатовый цвет, шартрез",["count"]=2}
Str[11]={["id"]=4,["name"]="Каштановый",["count"]=2}
Str[12]={["id"]=21,["name"]="Шоколадный",["count"]=2}
Str[13]={["id"]=7,["name"]="Коричный",["count"]=2}
Str[14]={["id"]=5,["name"]="Кобальт синий",["count"]=2}
Str[15]={["id"]=12,["name"]="Медный",["count"]=5}
Str[16]={["id"]=6,["name"]="Коралловый, кораллово-красный",["count"]=5}
Str[17]={["id"]=9,["name"]="Кукурузный",["count"]=5}
Str[18]={["id"]=2,["name"]="Васильковый",["count"]=5}
Str[19]={["id"]=8,["name"]="Кремовый",["count"]=5}
Str[20]={["id"]=18,["name"]="Тёмно-красный, кровавый,Малиновый",["count"]=5}
Str[21]={["id"]=20,["name"]="Циан, васильковый",["count"]=5}




	return Str
end
local Str1 = getStrT()
print("-------например индекс и таблица (сортировка по двум полям)---------")
local sort = function (a, b) return (a.count <= b.count) and (a.name < b.name) end
Str = stable_sort(Str1,sort)
--table.sort(Str,sort)
for i = 1, #Str, 1 do
	print(i,"=",Str[i].name , " id = ", Str[i].id, "count" , Str[i].count)
end


]]



