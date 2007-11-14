#import "AMUtil.h"

NSString* md5hash(NSString *input)
{
    unsigned char *hash = MD5((unsigned char*)[input cString], [input cStringLength], NULL);
	int i;
    
	NSMutableString *hashString = [NSMutableString string];
	
    // Convert the binary hash into a string
    for (i = 0; i < MD5_DIGEST_LENGTH; i++) {
		[hashString appendFormat:@"%02x", *hash++];
	}
    
    return hashString;
}