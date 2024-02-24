import { writable } from "svelte/store";

export const MenuItems = writable([
    {
        Id: 0,
        Name: "Test1",
        Label: "Test 1",
        Price: false,
        Children: [
            {
                Id: 0,
                Name: "Test1.1",
                Label: "Test 1.1"
            },
            {
                Id: 1,
                Name: "Test1.2",
                Label: "Test 1.2"
            },
            {
                Id: 2,
                Name: "Test1.3",
                Label: "Test 1.3"
            },
            {
                Id: 3,
                Name: "Test1.4",
                Label: "Test 1.4"
            },
            {
                Id: 4,
                Name: "Test1.5",
                Label: "Test 1.5"
            },
            {
                Id: 5,
                Name: "Test1.6",
                Label: "Test 1.6"
            },
            {
                Id: 6,
                Name: "Test1.7",
                Label: "Test 1.7"
            },
        ]
    },
    {
        Id: 1,
        Name: "Test2",
        Label: "Test 2",
        Price: false,
    },
    {
        Id: 2,
        Name: "Test3",
        Label: "Test 3",
    },
    {
        Id: 3,
        Name: "Test4",
        Label: "Test 4",
    },
    {
        Id: 4,
        Name: "Test5",
        Label: "Test 5",
    },
    {
        Id: 5,
        Name: "Test6",
        Label: "Test 6",
    },
    {
        Id: 6,
        Name: "Test7",
        Label: "Test 7",
    },
    {
        Id: 7,
        Name: "Test8",
        Label: "Test 8",
        Children: [
            {
                Id: 0,
                Name: "Test8.1",
                Label: "Child 1",
                Price: 0
            },
            {
                Id: 1,
                Name: "Test8.2",
                Label: "Child 2",
                Price: 15
            },
            {
                Id: 2,
                Name: "Test8.3",
                Label: "Child 3",
                Price: 310,
                Installed: true
            },
            {
                Id: 3,
                Name: "Test8.4",
                Label: "Child 4"
            },
            {
                Id: 4,
                Name: "Test8.5",
                Label: "Child 5"
            },
            {
                Id: 5,
                Name: "Test8.6",
                Label: "Child 6"
            },
            {
                Id: 6,
                Name: "Test8.7",
                Label: "Child 7"
            },
        ]
    },
    {
        Id: 8,
        Name: "Test9",
        Label: "Test 9",
    },
    {
        Id: 9,
        Name: "Test10",
        Label: "Test 10",
    },
    {
        Id: 10,
        Name: "Test11",
        Label: "Test 11",
    },
    {
        Id: 11,
        Name: "Test12",
        Label: "Test 12",
    },
    {
        Id: 12,
        Name: "Test13",
        Label: "Test 13",
    },
]);