function Insertion_Sort(array)
    for i in 1:size(array)[1] #we loop over the entire array
        j = i  #element i represents the card(s) in our hand, element j is the card from the deck
        while j>1 && (array[j-1] > array[j]) #if element j-1 is larger than element j...
            array[j-1],array[j] = array[j],array[j-1] #we swap them
            j = j-1
        end
    end
    return array
end

#First We define the function for the conquer step(i.e. the function to merge the subarrays)

function Merge(a1,a2) #the funciton takes two arrays
    C = []                                     #we generate an empy array C
    while size(a1)[1] != 0 && size(a2)[1] != 0 # while the size of both arrays is different from zero...
        if a1[1] < a2[1]                       # we confront the first elements of the two arrays...
            push!(C, popfirst!(a1))            # if the element of a1 is larger, we append it to C
        else 
            push!(C, popfirst!(a2))            # else, we append the element of a2
        end 
    end
    while size(a1)[1] != 0                     # while the size of the a1 is != 0 and size a2 == 0
        push!(C, popfirst!(a1))                # we append a1 to C
    end 
    while size(a2)[1] != 0                     # while the size of the a2 is != 0 and size a1 == 0
        push!(C, popfirst!(a2))                # we append a2 to C
    end 
    return C                                   # The array C contains the elements of a1 and a2 sorted
end            

#Next, we define the merge sort algorithm. As it is a divide and conquer algorithm, we can code it using recursion

function Merge_Sort(array) #the function takes an array
    n = size(array)[1]     
    if n == 1
        return array             #if the size of the array is equal to 1, we return the array (pretty obvious)
    end 
    left = array[1:div(n,2)]     #now we split the array into 2 subarrays, left and right
    right = array[div(n,2)+1:n]
    left = Merge_Sort(left)      # we call merge sort recursively on the left subarray 
    right = Merge_Sort(right)    # we call merge sort recursively on the right subarray
    final =  Merge(left, right)  # finally, we merge the two subarrays using the Merge.
    return final
end

#=
What is the trick of the algorithm?
Well, say that the array we want to sort is [1,-1,3,-10]

Merge_Sort([1,-1,3,-10])
    n = 4
    left = [1,-1]
    right = [3,-10]

    left =Merge_Sort([1,-1])  First Recursion Call
            n = 2
            left = [1]
            right = [-1] 
            left = Merge_Sort([1])  returns [1] (n=1)   Second Recursion Call
            right= Merge_Sort([-1]) returns [-1] (n=1)  Third Recursion Call
            final = Merge([1],[-1]) reutrns [-1,1]

    right = Merge_Sort([3,-10]) = [-10,3] Fourth Recursion Call (Same Logic as above)
    final = Merge([-1,1],[-10,3]) returs [-10,-1,1,3]
=#

#First, we code the partition function which rearrenges the subarray A[p..r] in place

function Partition(array,p,r)
    x = copy(array[r])
    i = p-1
    for j in p:r-1
        if array[j] <= x
            i = i+1
            swap = copy(array[i])
            array[i] = array[j]
            array[j] = swap
        end
    end
    swap = copy(array[i+1])
    array[i+1] = array[r]
    array[r] = swap
    return i+1
end

function Quick_Sort(array,p,r)
    if p<r
        q = Partition(array,p,r)
        Quick_Sort(array,p,q-1)
        Quick_Sort(array,q+1,r)
    end
    return array
end

function Partition_r(array, p, r)
    piv = rand(p:r)
    array[piv], array[r] = array[r], array[piv]
    return Partition(array, p, r)
end

function Quick_Sort_rand(array,p,r)
    if p<r
        q = Partition_r(array,p,r)
        Quick_Sort_rand(array,p,q-1)
        Quick_Sort_rand(array,q+1,r)
    end
    return array
end

function benchmarking(func,iter, worst = false)
    times = []
    array_size = []
    for i in 1:iter
        sum = 0
        for k in 1:1000
            if worst == true
                array = sort(rand(-100000:100000, 20*i), rev = true)
            else 
                array = rand(-100000:100000, 20*i)
            end
            t = @timed func(array)
            sum += t.time
        end
        mean = sum/1000
        push!(array_size, 20*i)
        push!(times,mean)
    end
    return array_size,times
end

function benchmarking_quick(func,iter, worst = false)
    times = []
    array_size = []
    for i in 1:iter
        sum = 0
        for k in 1:1000
            if worst == true
                array = sort(rand(-100000:100000, 20*i), rev = true)
            else 
                array = rand(-100000:100000, 20*i)
            end
            t = @timed func(array,1,20*i)
            sum += t.time
        end
        mean = sum/1000
        push!(array_size, 20*i)
        push!(times,mean)
    end
    return array_size,times
end

#using Pkg
#Pkg.add("Plots")
#Note: Uncomment the lines above to install the plotting package

using Plots
#plotlyjs()

sizes = 100
array_size_ins, times_ins = benchmarking(Insertion_Sort,sizes)
array_size_ms, times_ms = benchmarking(Merge_Sort,sizes)
array_size_qs, times_qs = benchmarking_quick(Quick_Sort,sizes)
array_size_qs_r, times_qs_r = benchmarking_quick(Quick_Sort_rand,sizes)
array_size_ins_w, times_ins_w = benchmarking(Insertion_Sort,sizes, true)
array_size_ms_w, times_ms_w = benchmarking(Merge_Sort,sizes, true)
array_size_qs_w, times_qs_w = benchmarking_quick(Quick_Sort,sizes, true)
array_size_qs_wr, times_qs_wr = benchmarking_quick(Quick_Sort_rand,sizes,true)
""

using Plots
scatter(array_size_ins, times_ins, label = "Insertion Sort")
scatter!(array_size_ms, times_ms, label = "Merge Sort")
scatter!(array_size_qs, times_qs, label = "Quick Sort")
scatter!(array_size_qs_r, times_qs_r, label = "Quick Sort (Randomized)")
p1 = plot!(size= (600,400), legend=:outertopright)
title!("Benchmarking - Average Case")
xlabel!("Size")
ylabel!("Time")
scatter(array_size_ins_w ,times_ins_w, label = "")
scatter!(array_size_ms_w, times_ms_w, label = "")
scatter!(array_size_qs_w, times_qs_w, label = "")
scatter!(array_size_qs_wr, times_qs_wr, label = "")
p2 = plot!(size= (600,400), legend=:outertopright)
title!("Benchmarking - Worst Case")
xlabel!("Size")
ylabel!("Time")
plot!(p1,p2, layout = (1,2),size= (950,400) )
