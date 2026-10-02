import 'package:flutter/material.dart';

const _skeletonColor = Color(0xFF242424);

class MovieSkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  const MovieSkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _skeletonColor,
        borderRadius: borderRadius,
      ),
    );
  }
}

class MovieGridSkeleton extends StatelessWidget {
  final int itemCount;

  const MovieGridSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      physics: const BouncingScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 18,
        childAspectRatio: 0.62,
      ),
      itemBuilder: (_, index) => const MovieGridSkeletonCard(),
    );
  }
}

class MovieGridSkeletonCard extends StatelessWidget {
  const MovieGridSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: MovieSkeletonBox(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        const SizedBox(height: 8),
        const MovieSkeletonBox(
          height: 14,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        const SizedBox(height: 7),
        const MovieSkeletonBox(
          width: 55,
          height: 11,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ],
    );
  }
}

class MovieRowSkeleton extends StatelessWidget {
  final int itemCount;

  const MovieRowSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, index) =>
            const SizedBox(width: 135, child: MovieGridSkeletonCard()),
      ),
    );
  }
}

class MovieDetailsSkeleton extends StatelessWidget {
  const MovieDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(
          child: MovieSkeletonBox(height: 540, borderRadius: BorderRadius.zero),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 26),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const MovieSkeletonBox(
                  height: 42,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(
                    3,
                    (index) => const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: MovieSkeletonBox(
                          height: 47,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const MovieSkeletonBox(width: 110, height: 18),
                const SizedBox(height: 12),
                ...List.generate(
                  5,
                  (index) => const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: MovieSkeletonBox(height: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
