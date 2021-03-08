extends Node


# Priority Queue implementation with binary heap
var heaplist
var currentSize

func _init():
	heaplist = [0]
	currentSize = 0

func percUp(i):
	while floor(i / 2) > 0:
		if heaplist[i].final_cost < heaplist[floor(i / 2)].final_cost:
			var tmp = heaplist[floor(i / 2)]
			heaplist[floor(i / 2)] = heaplist[i]
			heaplist[i] = tmp
		i = floor(i / 2)

func insert(k):
	heaplist.append(k)
	currentSize += 1
	percUp(currentSize)

func percDown(i):
	while (i * 2) <= currentSize:
		var mc = minChild(i)
		if heaplist[i].final_cost > heaplist[mc].final_cost:
			var tmp = heaplist[i]
			heaplist[i] = heaplist[mc]
			heaplist[mc] = tmp
		i = mc

func minChild(i):
	if i * 2 + 1 > currentSize:
		return i * 2
	else:
		if heaplist[i*2].final_cost < heaplist[i*2+1].final_cost:
			return i * 2
		else:
			return i * 2 + 1

func delMin():
	var retval = heaplist[1]
	heaplist[1] = heaplist[currentSize]
	heaplist.remove(currentSize - 1)
	currentSize -= 1
	percDown(1)
	return retval

func empty():
	return currentSize < 1
	
func peek():
	return heaplist[1]

func insert_or_resort(node):
	var index = heaplist.find(node)
	if index == -1:
		insert(node)
	else:
		percUp(index)
