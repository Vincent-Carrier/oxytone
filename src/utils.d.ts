export declare function trace(value: any, { kind, name }: ClassMethodDecoratorContext): (...args: any[]) => any;
export declare function cycle<T extends string>(...values: T[]): Iterator<T[number]>;
