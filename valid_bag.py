import bagit
bag = bagit.Bag("/media/baihong/UA\ Digital_init\ 9375/generic/Rutherford/69.164.1.2.3.1.1")
if bag.is_valid():
    print "yay :)"
else:
    print "boo :("
