//
//  main.c
//  RAMR3Demo
//
//  Created by 裘俊云 on 2018/11/14.
//  Copyright © 2018年 裘俊云. All rights reserved.
//

#include <stdio.h>
#include "r3.h"
#include <assert.h>

void test1() {
    node *n = r3_tree_create(10);
    
    int index1 = 1;
    // insert the route path into the router tree
    r3_tree_insert_path(n, "/bar1", &index1); // ignore the length of path
    
    r3_tree_insert_path(n, "/bar", &index1); // ignore the length of path
    
    int index2 = 2;
    r3_tree_insert_pathl(n, "/zoo", strlen("/zoo"), &index2 );
    
    int index3 = 3;
    r3_tree_insert_pathl(n, "/foo/bar", strlen("/foo/bar"), &index3 );
    
    int index4 = 4;
    r3_tree_insert_pathl(n ,"/post/{ab}/ab", strlen("/post/{id}/ab") , &index4 );
    
    int index5 = 5;
    r3_tree_insert_pathl(n, "/user/{id:\\d+}/{id1:\\d+}", strlen("/user/{id:\\d+}/{id1:\\d+}"), &index5 );
    
    
    // if you want to catch error, you may call the extended path function for insertion
    char *errstr = NULL;
    //    node *ret = r3_tree_insert_pathl_ex(n, "/foo/{name:\\d{5}", strlen("/foo/{name:\\d{5}"), NULL, &data, &errstr);
    //    if (ret == NULL) {
    //        // failed insertion
    //        printf("error: %s\n", errstr);
    //        free(errstr); // errstr is created from `asprintf`, so you have to free it manually.
    //    }
    
    
    // let's compile the tree!
    errstr = NULL;
    int err = r3_tree_compile(n, &errstr);
    if (err != 0) {
        // fail
        printf("error: %s\n", errstr);
        free(errstr); // errstr is created from `asprintf`, so you have to free it manually.
    }
    
    
    // dump the compiled tree
    r3_tree_dump(n, 0);
    
    
    // match a route
    NSMutableDictionary *matchedResult = [NSMutableDictionary new];
    node *matched_node = r3_tree_matchl(n, "/bar", strlen("/bar"), NULL, matchedResult);
    assert(matched_node && *( (int*) matched_node->data ) == 1 && matchedResult.count == 0);
    
    
    matched_node = r3_tree_matchl(n, "/foo/bar", strlen("/foo/bar"), NULL, matchedResult);
    assert(matched_node && *( (int*) matched_node->data ) == 3 && matchedResult.count == 0);
    
    matched_node = r3_tree_matchl(n, "/post/tt/cd", strlen("/post/tt/cd"), NULL, matchedResult);
    assert(!matched_node);
    [matchedResult removeAllObjects];
    
    matched_node = r3_tree_matchl(n, "/user/13/213", strlen("/user/13/213"), NULL, matchedResult);
    assert(matched_node && *( (int*) matched_node->data ) == 5);
    assert(matchedResult.count == 2 && [[matchedResult objectForKey:@"id"] isEqualToString:@"13"]
           && [[matchedResult objectForKey:@"id1"] isEqualToString:@"213"]);
    
    [matchedResult release];
    // release the tree
    r3_tree_free(n);
}

void test2() {
    node * n = r3_tree_create(3);
    
    r3_tree_insert_path(n, "/foo/bar/baz",  NULL);
    r3_tree_insert_path(n, "/foo/bar/qux",  NULL);
    r3_tree_insert_path(n, "/foo/bar/quux",  NULL);
    r3_tree_insert_path(n, "/bar/foo/baz",  NULL);
    r3_tree_insert_path(n, "/bar/foo/quux",  NULL);
    r3_tree_insert_path(n, "/bar/garply/grault",  NULL);
    r3_tree_insert_path(n, "/baz/foo/bar",  NULL);
    r3_tree_insert_path(n, "/baz/foo/qux",  NULL);
    r3_tree_insert_path(n, "/baz/foo/quux",  NULL);
    r3_tree_insert_path(n, "/qux/foo/quux",  NULL);
    r3_tree_insert_path(n, "/qux/foo/corge",  NULL);
    r3_tree_insert_path(n, "/qux/foo/grault",  NULL);
    r3_tree_insert_path(n, "/corge/quux/foo",  NULL);
    r3_tree_insert_path(n, "/corge/quux/bar",  NULL);
    r3_tree_insert_path(n, "/corge/quux/baz",  NULL);
    r3_tree_insert_path(n, "/corge/quux/qux",  NULL);
    r3_tree_insert_path(n, "/corge/quux/grault",  NULL);
    r3_tree_insert_path(n, "/grault/foo/bar",  NULL);
    r3_tree_insert_path(n, "/grault/foo/baz",  NULL);
    r3_tree_insert_path(n, "/garply/baz/quux",  NULL);
    r3_tree_insert_path(n, "/garply/baz/corge",  NULL);
    r3_tree_insert_path(n, "/garply/baz/grault",  NULL);
    r3_tree_insert_path(n, "/garply/qux/foo",  NULL);
    
    char *errstr = NULL;
    int err = r3_tree_compile(n, &errstr);
    if(err) {
        printf("%s\n",errstr);
        free(errstr);
        return;
    }
    
    node *m;
    
    NSMutableDictionary *matchedResult = [NSMutableDictionary new];
    m = r3_tree_matchl(n, "/qux/bar/corge", strlen("/qux/bar/corge"), NULL, matchedResult);
    
    match_entry * e = match_entry_createl("/garply/baz/grault", strlen("/garply/baz/grault") );
    m = r3_tree_match_entry(n , e);
    if (m) {
        printf("Matched! %s\n", e->path);
    }
    match_entry_free(e);
    r3_tree_free(n);
}

void test3() {
    // create a router tree with 10 children capacity (this capacity can grow dynamically)
    node *n = r3_tree_create(10);
    
    int route_data = 3;
    
    // insert the route path into the router tree
    r3_tree_insert_pathl(n , "/zoo"       , strlen("/zoo")       , &route_data );
    r3_tree_insert_pathl(n , "/foo/bar"   , strlen("/foo/bar")   , &route_data );
    r3_tree_insert_pathl(n , "/bar"       , strlen("/bar")       , &route_data );
    r3_tree_insert_pathl(n , "/post/{id}" , strlen("/post/{id}") , &route_data );
    r3_tree_insert_pathl(n , "/user/{id:\\d+}" , strlen("/user/{id:\\d+}") , &route_data );
    
    // let's compile the tree!
    char *errstr = NULL;
    r3_tree_compile(n, &errstr);
    
    
    // dump the compiled tree
    r3_tree_dump(n, 0);
    
    // match a route
    NSMutableDictionary *matchedResult = [NSMutableDictionary new];
    node *matched_node = r3_tree_matchl(n, "/foo/bar", strlen("/foo/bar"), NULL, matchedResult);
    if (matched_node) {
        printf("%c\n", matched_node->endpoint);// make sure there is a route end at here.
        printf("%s\n", matched_node->data);
    }
    r3_tree_free(n);
}

int main(int argc, const char * argv[]) {
    // insert code here...
    test1();
    printf("---------------\n");
    test2();
    printf("---------------\n");
    test3();
    printf("Hello, World!\n");
    return 0;
}
